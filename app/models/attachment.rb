class Attachment
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :attachment, String,
    required: true, message: I18n.t('active_record.errors.messages.blank')
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  belongs_to :subject, :polymorphic => true, required: true, suffix: 'type'

  mount_uploader :attachment, AttachmentUploader
end
