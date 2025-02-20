class PgCron < Formula
  desc "Cron-based job scheduler for PostgreSQL 10+"
  homepage "https://github.com/citusdata/pg_cron#readme"
  url "https://github.com/citusdata/pg_cron/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "45bb16481b7baab5d21dfa399b7bfa903dd334ff45a644ae81506a1ec0be0188"
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
    system "make"
    system "make", "install", "DESTDIR=#{stagepath}"
    # pgxs always appends the full homebrew prefix to the destdir so we can't
    # install straight into the prefix, we need to stage it and then strip the
    # homebrew prefix while copying into the cellar.
    (stagepath/HOMEBREW_PREFIX.to_s.delete_prefix("/")).children.each do |subdir|
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

      shared_preload_libraries = 'pg_cron'

      cron.database_name = 'postgres'

      The file can be found here for the default configuration:

      #{postgresql_conf}
      
      Then restart your postgresql server:

      brew services restart postgresql
    EOS
  end
end
