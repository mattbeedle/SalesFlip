class Attachment
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :attachment, String

  # belongs_to :subject, :polymorphic => true
  # validates_presence_of :subject

  validates_with_method :validate_attachment

  mount_uploader :attachment, AttachmentUploader

protected
  def validate_attachment
    if self.attachment.blank?
      self.errors.add :attachment, I18n.t('active_record.errors.messages.blank')
    end
  end
end
