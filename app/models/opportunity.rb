class Opportunity
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include Assignable
  include ParanoidDelete
  include Activities
  include Permission
  # include Sunspot::Mongoid

  property :id, Serial
  property :title, String, :required => true
  property :close_on, Date,    :default => lambda { |*| 1.month.from_now.utc }
  property :probability, Integer, :default => 100
  property :amount, Float,   :default => 0.0
  property :discount, Float,   :default => 0.0
  property :background_info, String
  property :margin, Float
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  belongs_to :contact, required: false

  belongs_to :user, :required => true
  belongs_to :stage, model: 'OpportunityStage'

  has n, :comments, :as => :commentable#, :dependent => :delete_all
  has n, :tasks, :as => :asset#, :dependent => :delete_all
  has n, :attachments, :as => :subject

  def self.for_company(company)
    all(:user_id => company.users.map(&:id))
  end

  def self.closing_for_date(date)
    all(:close_on => date)
  end

  def self.closing_between_dates(start_date, end_date)
    all(:close_on.gte => start_date, :close_on.lte => end_date)
  end

  def self.certainty
    all(:probability => 100)
  end

  def self.created_on(date)
    all(:created_at.gte => date.beginning_of_day.utc,
        :created_at.lte => date.end_of_day.utc)
  end

  before :save, :set_probability
  before :save, :update_close_date

  alias :name  :title
  alias :name= :title=

  # searchable do
    # text :title, :background_info
  # end

  def self.stage_is( stages )
    stages = stages.lines.to_a if stages.respond_to?(:lines)
    all(:stage_id => OpportunityStage.all(:name => stages).map(&:id))
  end

  def weighted_amount
    ((amount || 0.0)  - (discount || 0.0)) * (probability || 0) / 100.0
  end

  def attachments_attributes=( attachments_attributes )
    attachments_attributes.each do |attributes|
      self.attachments.build attributes.merge(:subject => self)
    end
    self.attachments.first.valid?
  end

  def self.create_for( contact, options = {} )
    attributes = options[:opportunity] || {}
    opportunity = contact.opportunities.new attributes.merge(:user => contact.user,
      :assignee => contact.assignee)
    opportunity.save if contact.valid? && !opportunity.title.blank?
    opportunity
  end

  def set_probability
    self.probability = self.stage.percentage
  end

  def update_close_date
    if self.probability == 100 && changed.include?('probability')
      self.close_on = Date.today
    end
  end
end
