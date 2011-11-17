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

  def self.export
    all.each do |attachment|
      begin
        attachment.export
      rescue
      end
    end
  end

  def export
    data = self.attachment.read
    vals = [self.subject_id, self.subject_type, self.attachment.url.split('/').last]
    File.open("tmp/files/#{vals.join('-')}", 'w+b') do |file|
      file.write data
    end if data
  end
end
