class Company
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  references_many :users, :index => true

  validates_presence_of :name
  validates_uniqueness_of :name
end
