class Company
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  has n, :users
end
