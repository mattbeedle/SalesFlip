class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasConstant
  include HasConstant::Orm::Mongoid
  include Mongoid::Rails::MultiParameterAttributes
  include Assignable
  include ParanoidDelete
  include Activities
  include Permission
  include Sunspot::Mongoid

  field :title
  field :close_on,        :type => Date,    :default => lambda { 1.month.from_now.utc }
  field :probability,     :type => Integer, :default => 100
  field :amount,          :type => Float,   :default => 0.0
  field :discount,        :type => Float,   :default => 0.0
  field :background_info

  referenced_in :contact
  referenced_in :user
  referenced_in :stage, :class_name => 'OpportunityStage'
  references_many :comments, :as => :commentable, :dependent => :delete_all
  references_many :tasks, :as => :asset, :dependent => :delete_all
  references_many :attachments, :as => :subject, :index => true

  validates_presence_of :title, :user, :stage

  named_scope :for_company, lambda { |company| { :where => { :user_id.in => company.users.map(&:id) } } }

  before_save :set_probability

  alias :name :title

  searchable do
    text :title, :background_info
  end

  def self.stage_is( stages )
    stages = stages.lines.to_a if stages.respond_to?(:lines)
    where(:stage_id.in => OpportunityStage.where(:name.in => stages).map(&:id))
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
    opportunity = contact.opportunities.build attributes.merge(:user => contact.user,
      :assignee => contact.assignee)
    opportunity.save if contact.valid? && !opportunity.title.blank?
    opportunity
  end

  def set_probability
    self.probability = self.stage.percentage
  end
end
