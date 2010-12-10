class Objective
  include Mongoid::Document

  field :number_of_leads, :type => Integer
  field :conversion_percentage, :type => Integer

  embedded_in :campaign, :inverse_of => :objective

  validates_presence_of :number_of_leads, :if => :conversion_percentage?

  def number_of_conversions
    if conversion_percentage?
      (number_of_leads * conversion_percentage / 100.0).to_i
    else
      "N/A"
    end
  end
end
