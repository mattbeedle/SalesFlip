class OpportunityStage
  include DataMapper::Resource
  include DataMapper::Timestamps
  # include Mongoid::I18n
  include ParanoidDelete

  property :id, Serial
  property :name, String # should be 'localized_field'
  property :percentage, Integer, :required => true
  property :notes, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  belongs_to :company, :required => false
  has n, :opportunities

  validates_numericality_of :percentage, :allow_blank => true
end
