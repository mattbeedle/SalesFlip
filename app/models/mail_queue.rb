class MailQueue
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :mail, String, :required => true
  property :status, String
end
