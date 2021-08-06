class PgPartman < Formula
  desc "Partition management extension for PostgreSQL"
  homepage "https://pgxn.org/dist/pg_partman/doc/pg_partman.html"
  url "https://github.com/pgpartman/pg_partman/archive/refs/tags/v4.5.1.tar.gz"
  sha256 "c37ca049d37eb5a6fceea805007acfadaadd2c2fa70938ffb6f7a918b5772c37"
  license "PostgreSQL"

  depends_on "postgresql"

  def postgresql
    Formula["postgresql"]
  end

  def postgresql_cellar
    # Formula["postgresql"].versioned_prefix is what we want, but it's a private method
    postgresql.rack/postgresql.pkg_version.to_s
  end

  def postgresql_datadir
    var/"postgres"
  end

  def postgresql_conf
    postgresql_datadir/"postgresql.conf"
  end

  def stagepath
    buildpath/"stage"
  end

  def install
    stagepath.mkdir
    system "make", "install", "DESTDIR=#{stagepath}"
    # pgxs installs into places based on the postgresql installation path, so we need to unwind it a bit.
    # Some files are installed into DESTDIR/opt/homebrew/Cellar/postgresql/13.3/...
    (stagepath/postgresql_cellar.to_s.delete_prefix("/")).children.each do |subdir|
      (prefix/subdir.basename).install subdir.children
    end
    # Some files are installed into DESTDIR/opt/homebrew/...
    (stagepath/HOMEBREW_PREFIX.to_s.delete_prefix("/")).children.each do |subdir|
      next if subdir.basename == HOMEBREW_CELLAR.basename
      (prefix/subdir.basename).install subdir.children
    end
  end

  test do
    system "false"
  end

  def caveats
    <<~EOS
      You must edit your postgresql configuration and set the following
      parameters, modified as needed:

      shared_preload_libraries = 'pg_partman_bgw'

      pg_partman_bgw.interval = 3600
      pg_partman_bgw.role = '#{ENV.fetch("USER")}'
      pg_partman_bgw.dbname = 'postgres'

      The file can be found here for the default configuration:

      #{postgresql_conf}
      
      Then restart your postgresql server:

      brew services restart postgresql
    EOS
  end
end
