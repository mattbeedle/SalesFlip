class FixAttachments < Migrations::MongodbToPostgresql
  def self.up
    Attachment.all.each do |attachment|
      begin
        file = CarrierWave::Storage::GridFS::File.new(AttachmentUploader, attachment.attachment.store_path(attachment.attachment_filename))
        f = File.open(attachment.attachment_filename, 'w+') do |the_file|
          the_file.write file.read.force_encoding('iso-8859-1')
        end
        a = Attachment.new :subject => attachment.subject, :attachment => f
        a.save
        a.created_at = attachment.created_at
        a.created_on = Date.parse(attachment.created_at.to_s)
        a.updated_at = attachment.updated_at
        a.updated_on = Date.parse(attachment.updated_at.to_s)
        a.save!
      rescue StandardError => e
        puts e
        puts attachment.legacy_id
      ensure
        begin
          FileUtils.rm(attachment.attachment_filename) if attachment.attachment_filename
          attachment.destroy
        rescue
        end
      end
    end
  end

  def self.down
  end
end
