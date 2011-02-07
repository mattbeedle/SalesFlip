class FixAttachments < Migrations::MongodbToPostgresql
  def self.up
    Attachment.where(:attachment_filename => nil).each &:destroy
    Attachment.where(:attachment_filename.not => nil).each do |attachment|
      begin
        filename = attachment.attachment_filename

        original_file_path = attachment.attachment.store_path(filename)

        attachment.attribute_set :attachment, filename
        attachment.attachment_filename = nil
        attachment.legacy_id = nil

        new_file_path = attachment.attachment.store_path(filename)

        grid.open(new_file_path, 'w') do |new_file|
          grid.open(original_file_path, 'r') do |original_file|
            original_file.each do |chunk|
              new_file.write(chunk)
            end
          end
        end

        grid.delete(original_file_path)

        attachment.save!
      rescue StandardError => e
        puts e
        puts attachment.legacy_id
        attachment.destroy
      end
    end
  end

  def self.grid
    @grid ||= begin
      if Rails.env.staging?
        db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db(database)
        db.authenticate(ENV['MONGODB_STAGING_USER'], ENV['MONGODB_STAGING_PASSWORD'])
      elsif Rails.env.production?
        db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db('salesflip')
        db.authenticate(ENV['MONGODB_USER'], ENV['MONGODB_PASSWORD'])
      else
        db = Mongo::Connection.new.db(database)
      end
      Mongo::GridFileSystem.new(db)
    end
  end

  def self.down
  end
end
