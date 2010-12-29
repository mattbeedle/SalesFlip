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
  has n, :opportunity_stages, :order => :percentage.asc

  before :create, :init_opportunity_stages

protected
  def init_opportunity_stages
    [['prospecting', 10], ['analysis', 20], ['presentation', 40], ['negotiation', 70],
      ['final review', 90], ['closed/won', 100], ['closed/lost', 0]].each do |stage|
      opportunity_stages << OpportunityStage.new(:name => stage.first, :percentage => stage.last)
    end
  end
end
