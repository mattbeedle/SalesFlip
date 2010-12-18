class Company
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  references_many :users, :index => true
  references_many :opportunity_stages, :default_order => :percentage.asc

  validates_presence_of :name
  validates_uniqueness_of :name

  before_create :init_opportunity_stages

protected
  def init_opportunity_stages
    [['prospecting', 10], ['analysis', 20], ['presentation', 40], ['negotiation', 70],
      ['final review', 90], ['closed/won', 100], ['closed/lost', 0]].each do |stage|
      opportunity_stages << OpportunityStage.new(:name => stage.first, :percentage => stage.last)
    end
  end
end
