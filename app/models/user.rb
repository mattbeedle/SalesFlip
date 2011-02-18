class User
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include Gravtastic
  is_gravtastic

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  property :id, Serial
  property :username, String
  property :api_key, String
  property :first_name, String
  property :last_name, String
  property :type, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
  property :assigned_lead_count, Integer, default: 0

  attr_accessor :company_name

  has n,  :leads
  has n,  :comments
  has n,  :emails
  has n,  :tasks
  has n,  :accounts
  has n,  :contacts
  has n,  :activities,  child_key: 'creator_id'
  has n,  :searches
  has n,  :invitations, :inverse => :inviter#, :dependent => :destroy
  has 1,  :invitation,  :inverse => :invited
  has n,  :opportunities
  has n,  :assigned_opportunities, child_key: 'assignee_id',
    model: 'Opportunity'
  has n, :lead_imports

  belongs_to :company, :required => true

  before :valid? do
    set_api_key if new?
  end

  before :valid? do
    create_company if new?
  end

  before :create, :set_default_role
  after :create, :update_invitation

  has_constant :roles, ROLES

  def invitation_code=( invitation_code )
    if invitation = Invitation.first(:code => invitation_code)
      self.invitation = invitation
      self.company_id = invitation.inviter.company_id
      self.username = invitation.email.split('@').first if self.username.blank?
      self.email = invitation.email if self.email.blank?
      self.role = invitation.role
    end
  end

  def deleted_items_count
    count  = Lead.permitted_for(self).deleted.count
    count += Contact.permitted_for(self).deleted.count
    count += Account.permitted_for(self).deleted.count
    count += Comment.permitted_for(self).deleted.count
  end

  def full_name
    username.present? ? username : email.split('@').first
  end
  alias :name :full_name

  def recent_items
    activities.where(:action => 'Viewed', :order => :updated_at.desc,
                     :limit => 5).map(&:subject).compact
  end

  def tracked_items
    (Lead.tracked_by(self).entries +
     Contact.tracked_by(self).entries +
     Account.tracked_by(self).entries
    ).sort_by &:created_at
  end

  def self.send_tracked_items_mail
    User.all.each do |user|
      UserMailer.tracked_items_update(user).deliver if user.new_activity?
      user.tracked_items.each do |item|
        item.related_activities.not_notified(user).each do |activity|
          activity.update :notified_user_ids => (activity.notified_user_ids || []) << user.id
        end
      end
    end
  end

  def new_activity?
    (self.tracked_items.map {|i| i.related_activities.not_notified(self).count }.
      inject {|sum,n| sum += n } || 0) > 0
  end

  def dropbox_email
    "#{api_key}@salesflip.appspotmail.com"
  end

  def self.update_cached_lead_counts(user_id)
    user = User.find(user_id)
    user.assigned_lead_count = Lead.for_company(user.company).
      assigned_to(user).count
    user.save
  end

  def redistribute_leads(options = {})
    sales_people = company.reload.users.where(:id.not => id).
      role_is('Sales Person')
    unless sales_people.blank?
      users = options[:users] || sales_people
      chunks = leads.to_a.chunk(users.count)
      users.each_with_index do |user, index|
        chunks[index].each do |lead|
          lead.update_attributes :assignee => user, :do_not_log => true,
            :do_not_notify => true
        end
      end
    end
  end

protected
  def set_api_key
    UUID.state_file = false # for heroku
    self.api_key = UUID.new.generate
  end

  def create_company
    company = Company.new :name => self.company_name
    self.company = company if company.save
  end

  def update_invitation
    # invitation.update :invited_id => self.id if invitation
  end

  def set_default_role
    self.role = 'Sales Person' if self.role.blank?
  end
end
