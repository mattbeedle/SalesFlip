class Objective
  include DataMapper::Resource

  property :id, Serial
  property :number_of_leads, Integer
  property :conversion_percentage, Integer

  belongs_to :campaign, required: false

  after :valid? do |success, context = :default|
    if !success && campaign
      campaign.errors[:objective] ||= errors.to_hash
    end
  end

  validates_presence_of :number_of_leads, :if => :conversion_percentage?
  validates_numericality_of :conversion_percentage, allow_blank: true,
    allow_nil: true

  def conversion_percentage?
    conversion_percentage.present?
  end

  def number_of_conversions
    if conversion_percentage?
      (number_of_leads * conversion_percentage / 100.0).to_i
    else
      "N/A"
    end
  end
end
