class InfomailTemplate
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :name, String
  property :body, Text

  belongs_to :campaign, required: false
  has n, :attachments, as: :subject

  def attachments_attributes=(attributes)
    return if attributes.all? &:blank?

    attachments.clear
    (attributes || []).each do |attachment|
      attachments.build(attachment) if attachment
    end
  end

end
