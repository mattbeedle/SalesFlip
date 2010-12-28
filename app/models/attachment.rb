class Attachment
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :attachment, String,
    required: true, message: I18n.t('active_record.errors.messages.blank')

  belongs_to :subject, :polymorphic => true, required: true, suffix: 'type'

  mount_uploader :attachment, AttachmentUploader
end
