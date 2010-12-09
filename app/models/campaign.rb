class Campaign
  include Mongoid::Document

  field :name
  field :start_date, :type => Date
  field :end_date, :type => Date

  validates_presence_of :name

end
