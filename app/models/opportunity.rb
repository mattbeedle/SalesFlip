class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasConstant
  include HasConstant::Orm::Mongoid
  include Mongoid::Rails::MultiParameterAttributes
  include Assignable
  include ParanoidDelete
  include Permission
  
  field :title
  field :stage,           :type => Integer
  field :close_on,        :type => Date,    :default => lambda { 1.month.from_now.utc }
  field :probability,     :type => Integer, :default => 100
  field :amount,          :type => Float,   :default => 0.0
  field :discount,        :type => Float,   :default => 0.0
  field :background_info
  
  belongs_to_related :contact
  belongs_to_related :user
  has_many_related :comments, :as => :commentable, :dependent => :delete_all
  has_many_related :tasks, :as => :asset, :dependent => :delete_all
  has_many_related :attachments, :as => :subject, :index => true
  
  validates_presence_of :title
  
  named_scope :for_company, lambda { |company| { :where => { :user_id.in => company.users.map(&:id) } } }
  
  has_constant :stages, lambda { I18n.t(:opportunity_stages) }
  
  before_create :init_stage
  
  alias :name :title
  
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
  
protected
  def init_stage
    self.stage = 'prospecting' if self.stage.blank?
  end
end