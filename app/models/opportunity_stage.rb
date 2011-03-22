class OpportunityStage
  include DataMapper::Resource
  include DataMapper::Timestamps
  # include Mongoid::I18n
  include ParanoidDelete

  property :id, Serial
  property :name, String, required: true # should be 'localized_field'
  property :percentage, Integer, required: true
  property :notes, String
  property :step, Integer
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  belongs_to :company, :required => false
  has n, :opportunities, child_key: :stage_id

  validates_numericality_of :percentage, :allow_blank => true

  class << self
    def ordered
      all(order: [ :step.asc ])
    end
  end
end
