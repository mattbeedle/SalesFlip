class BackupJob
  @queue = :backup

  class << self

    def perform
      Net::SSH.start("78.47.226.213", "root") do |ssh|
        ssh.exec("tar -vf ~/main.tar /var/lib/postgresql/9.0/main")
      end
      Net::SCP.download!("78.47.226.213", "root", "~/main.tar", "~/main.tar")
      upload_backup
    end

    private

    def bucket
      AWS.directories.create(
        key: "salesflip-backup-#{Time.now.to_i}",
        public: false
      )
    end

    def upload_backup
      bucket.files.create(
        key: "main.tar",
        body: File.open("~/main.tar"),
        public: false
      )
    end
  end
end
