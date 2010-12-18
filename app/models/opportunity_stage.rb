class OpportunityStage
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::I18n
  include ParanoidDelete

  localized_field :name
  field :percentage,    :type => Integer
  field :notes

  referenced_in :company
  references_many :opportunities

  validates_presence_of :name, :percentage
  validates_numericality_of :percentage, :allow_blank => true
end
