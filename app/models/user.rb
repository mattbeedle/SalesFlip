class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasConstant
  include HasConstant::Orm::Mongoid
  include Gravtastic
  is_gravtastic

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  field :username
  field :api_key
  field :role,      :type => Integer
  field :type

  attr_accessor :company_name

  references_many  :leads,       :index => true
  references_many  :comments,    :index => true
  references_many  :emails,      :index => true
  references_many  :tasks,       :index => true
  references_many  :accounts,    :index => true
  references_many  :contacts,    :index => true
  references_many  :activities,  :index => true
  references_many  :searches,    :index => true
  references_many  :invitations, :as => :inviter, :dependent => :destroy, :index => true
  references_one   :invitation,  :as => :invited, :index => true
  references_many  :opportunities, :index => true
  references_many  :assigned_opportunities, :foreign_key => 'assignee_id',
    :class_name => 'Opportunity', :index => true

  referenced_in :company

  before_validation :set_api_key, :create_company, :on => :create
  before_create :set_default_role
  after_create :update_invitation

  has_constant :roles, ROLES

  validates_presence_of :company

  def invitation_code=( invitation_code )
    if @invitation = Invitation.first(:conditions => { :code => invitation_code })
      self.company_id = @invitation.inviter.company_id
      self.username = @invitation.email.split('@').first if self.username.blank?
      self.email = @invitation.email if self.email.blank?
      self.role = @invitation.role
    end
  end

  def deleted_items_count
    [Lead, Contact, Account, Comment].map do |model|
      model.permitted_for(self).deleted.count
    end.inject {|sum, n| sum += n }
  end

  def full_name
    username.present? ? username : email.split('@').first
  end
  alias :name :full_name

  def recent_items
    Activity.where(:user_id => self.id,
                   :action => I18n.locale_around(:en) { Activity.actions.index('Viewed') }).
                   desc(:updated_at).limit(5).map(&:subject)
  end

  def tracked_items
    (Lead.tracked_by(self) + Contact.tracked_by(self) + Account.tracked_by(self)).
      sort_by(&:created_at)
  end

  def self.send_tracked_items_mail
    User.all.each do |user|
      UserMailer.tracked_items_update(user).deliver if user.new_activity?
      user.tracked_items.each do |item|
        item.related_activities.not_notified(user).each do |activity|
          activity.update_attributes :notified_user_ids => (activity.notified_user_ids || []) << user.id
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
    @invitation.update_attributes :invited_id => self.id unless @invitation.nil?
  end

  def set_default_role
    self.role = 'Sales Person' if self.role.blank?
  end
end
