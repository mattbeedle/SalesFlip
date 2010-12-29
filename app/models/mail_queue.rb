class MailQueue
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :mail, String, :required => true
  property :status, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
end
