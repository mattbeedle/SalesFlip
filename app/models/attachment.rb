class Attachment
  include DataMapper::Resource
  include DataMapper::Timestamps
  include Exportable

  property :id, Serial
  property :attachment, String, auto_validation: false
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
  property :legacy_id,  String
  property :attachment_filename, String

  belongs_to :subject, :polymorphic => true, required: true

  validates_presence_of :attachment

  mount_uploader :attachment, AttachmentUploader

  def self.export_files
    all.each do |attachment|
      begin
        attachment.export_file(self.grid)
      rescue
      end
    end
  end

  def export_file(grid)
    file = grid.open(attachment.url.gsub(/^\/uploads\//, ''), 'r')
    vals = [
      self.subject_id, self.subject_type, self.attachment.url.split('/').last
    ]
    File.open("tmp/files/#{vals.join('-')}", 'w+b') do |f|
      f.write file.read
    end
  rescue Mongo::GridFileNotFound => e
    puts e.message
  end

  def self.connection
    Mongo::Connection.new(ENV['MONGODB_HOST'] || 'localhost', 27017)
  end

  def self.db
    @db ||= connection.db("salesflip_#{Rails.env}".gsub(/_$/, ''))
    if ENV['MONGODB_USER'] && ENV['MONGODB_PASSWORD']
      @db.authenticate(ENV['MONGODB_USER'], ENV['MONGODB_PASSWORD'])
    end
    @db
  end

  def self.grid
    @grid ||= Mongo::GridFileSystem.new(db)
  end
end
