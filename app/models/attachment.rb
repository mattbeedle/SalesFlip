class Attachment
  include DataMapper::Resource
  include DataMapper::Timestamps

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
end
