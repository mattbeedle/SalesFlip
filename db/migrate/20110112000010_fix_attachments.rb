class FixAttachments < Migrations::MongodbToPostgresql
  def self.up
    Attachment.where(:attachment_filename => nil).each &:destroy
    Attachment.where(:attachment_filename.not => nil).each do |attachment|
      begin
        File.open(attachment.attachment_filename, 'wb+') do |file|
          file.write grid.open(attachment.attachment.store_path(
            attachment.attachment_filename), 'r').read
        end
        a = Attachment.new :subject => attachment.subject,
          :attachment => File.open(attachment.attachment_filename)
        a.save
        a = Attachment.find(a.id)
        a.created_at = attachment.created_at
        a.created_on = attachment.created_at ? Date.parse(attachment.created_at.to_s) : nil
        a.updated_at = attachment.updated_at
        a.updated_on = attachment.updated_at ? Date.parse(attachment.updated_at.to_s) : nil
        a.save!
        attachment.destroy
        FileUtils.rm(attachment.attachment_filename) if File.exists?(attachment.attachment_filename)
      rescue StandardError => e
        puts e
        puts attachment.legacy_id
        attachment.destroy
      end
    end
  end

  def self.grid
    if Rails.env.staging?
      db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db(database)
      db.authenticate(ENV['MONGODB_STAGING_USER'], ENV['MONGODB_STAGING_PASSWORD'])
    elsif Rails.env.production?
      db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db(database)
      db.authenticate(ENV['MONGODB_USER'], ENV['MONGODB_PASSWORD'])
    else
      db = Mongo::Connection.new.db(database)
    end
    grid = Mongo::GridFileSystem.new(db)
  end

  def self.down
  end
end
