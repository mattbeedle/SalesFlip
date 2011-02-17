require "net/ssh"
require "net/scp"

class BackupJob
  @queue = :backup

  class << self

    def perform
      backup_postgres
      backup_mongo
      upload_backups
      delete_backups
    end

    private

    def backup_postgres
      Net::SSH.start("178.63.20.76", "root") do |ssh|
        ssh.exec("tar -cf ~/postgres.tar /var/lib/postgresql/9.0/main")
        ssh.exec("gzip -9 ~/postgres.tar")
      end
      Net::SCP.download!("178.63.20.76", "root", "postgres.tar.gz", "postgres.tar.gz")
      Net::SSH.start("178.63.20.76", "root") do |ssh|
        ssh.exec("rm ~/postgres.tar.gz")
      end
    end

    def backup_mongo
      Net::SSH.start("46.4.62.14", "root") do |ssh|
        ssh.exec("tar -cf ~/mongodb.tar /data/db/salesflip.*")
        ssh.exec("gzip -9 ~/mongodb.tar")
      end
      Net::SCP.download!("46.4.62.14", "root", "mongodb.tar.gz", "mongodb.tar.gz")
      Net::SSH.start("46.4.62.14", "root") do |ssh|
        ssh.exec("rm ~/mongodb.tar.gz")
      end
    end

    def bucket
      @bucket ||= Fog::Storage.new(provider: "AWS").directories.create(
        key: "salesflip-#{Rails.env}-backup-#{Time.now.to_i}",
        public: false
      )
    end

    def delete_backups
      File.delete("postgres.tar.gz")
      File.delete("mongodb.tar.gz")
    end

    def upload_backups
      bucket.files.create(
        key: "postgres.tar",
        body: File.open("postgres.tar.gz"),
        public: false
      )
      bucket.files.create(
        key: "mongodb.tar",
        body: File.open("mongodb.tar.gz"),
        public: false
      )
    end
  end
end
