class Company
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  # Cached lead counts
  property :new_lead_count, Integer, default: 0
  property :contacted_lead_count, Integer, default: 0
  property :converted_lead_count, Integer, default: 0
  property :rejected_lead_count, Integer, default: 0
  property :interested_lead_count, Integer, default: 0
  property :not_interested_lead_count, Integer, default: 0
  property :unassigned_lead_count, Integer, default: 0
  property :campaign_lead_count, Integer, default: 0
  property :cold_call_lead_count, Integer, default: 0
  property :conference_lead_count, Integer, default: 0
  property :imported_lead_count, Integer, default: 0
  property :online_marketing_lead_count, Integer, default: 0
  property :other_lead_count, Integer, default: 0
  property :referal_lead_count, Integer, default: 0
  property :self_generated_lead_count, Integer, default: 0
  property :website_lead_count, Integer, default: 0
  property :word_of_mouth_lead_count, Integer, default: 0

  has n, :users
  has n, :opportunity_stages, :order => :percentage.asc

  before :create, :init_opportunity_stages

  def update_cached_lead_counts
    attributes = {
      :unassigned_lead_count => Lead.for_company(self).unassigned.count
    }
    Lead.statuses.each do |status|
      attributes.merge!(
        "#{status.downcase.gsub(/\s/, '_')}_lead_count" => Lead.for_company(self).
        status_is(status).count)
    end
    Lead.sources.each do |source|
      attributes.merge!(
        "#{source.downcase.gsub(/[\s\-]/, '_')}_lead_count" =>
        Lead.for_company(self).source_is(source).count)
    end
    update_attributes attributes
  end

protected
  def init_opportunity_stages
    [['prospecting', 10], ['analysis', 20], ['presentation', 40], ['negotiation', 70],
      ['final review', 90], ['closed/won', 100], ['closed/lost', 0]].each do |stage|
      opportunity_stages << OpportunityStage.new(:name => stage.first, :percentage => stage.last)
    end
  end
end
