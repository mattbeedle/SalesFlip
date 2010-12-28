class OpportunityStage
  include DataMapper::Resource
  include DataMapper::Timestamps
  # include Mongoid::I18n
  include ParanoidDelete

  # localized_field :name
  property :id, Serial
  property :percentage, Integer, :required => true
  property :notes, String, :required => true

  belongs_to :company
  has n, :opportunities

  validates_numericality_of :percentage, :allow_blank => true
end
