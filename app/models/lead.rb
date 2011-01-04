class Lead
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasConstant
  include HasConstant::Orm::Mongoid
  include ParanoidDelete
  include Permission
  include Trackable
  include Activities
  include Sunspot::Mongoid
  include Gravtastic
  include ActiveModel::Observing
  is_gravtastic

  field :first_name
  field :last_name
  field :email
  field :phone
  field :status,        :type => Integer
  field :source,        :type => Integer
  field :rating,        :type => Integer
  field :notes

  field :title,         :type => Integer
  field :salutation,    :type => Integer
  field :company
  field :company_phone
  field :company_blog
  field :company_facebook
  field :company_twitter
  field :website
  field :career_site
  field :job_title
  field :department
  field :alternative_email
  field :fax
  field :mobile
  field :address
  field :city
  field :postal_code
  field :country
  field :referred_by
  field :do_not_call,   :type => Boolean

  field :twitter
  field :linked_in
  field :facebook
  field :xing
  field :identifier,    :type => Integer

  index(
    [
      [ :first_name, Mongo::ASCENDING ],
      [ :last_name, Mongo::ASCENDING ]
    ],
  )

  index(
    [
      [:status, Mongo::DESCENDING],
      [:created_at, Mongo::DESCENDING]
    ]
  )

  validates_presence_of :user, :last_name

  attr_accessor :do_not_notify

  belongs_to_related  :user, :index => true
  belongs_to_related  :assignee, :class_name => 'User', :index => true
  belongs_to_related  :contact, :index => true
  has_many_related    :comments, :as => :commentable, :dependent => :delete_all, :index => true
  has_many_related    :tasks, :as => :asset, :dependent => :delete_all, :index => true
  has_many_related    :emails, :as => :commentable, :dependent => :delete_all, :index => true

  before_validation :set_initial_state
  before_create     :set_identifier, :set_recently_created
  before_save       :log_recently_changed
  after_save        :notify_assignee, :unless => :do_not_notify

  has_constant :titles, lambda { I18n.t(:titles) }
  has_constant :statuses, lambda { I18n.t(:lead_statuses) }
  has_constant :sources, lambda { I18n.t(:lead_sources) }
  has_constant :salutations, lambda { I18n.t(:salutations) }

  named_scope :with_status, lambda { |statuses| { :where => {
    :status.in => statuses.map { |status| Lead.statuses.index(status) } } } }
  named_scope :unassigned, :where => { :assignee_id => nil }
  named_scope :assigned_to, lambda { |user_id| { :where => { :assignee_id => user_id } } }
  named_scope :for_company, lambda { |company| { :where => { :user_id.in => company.users.map(&:id) } } }

  searchable do
    text :first_name, :last_name, :email, :phone, :notes, :company, :alternative_email, :mobile,
      :address, :referred_by, :website, :twitter, :linked_in, :facebook, :xing
  end
  handle_asynchronously :solr_index

  def self.with_status( statuses )
    statuses = statuses.lines if statuses.respond_to?(:lines)
    where(:status.in => statuses.map { |status| Lead.statuses.index(status) })
  end

  def self.exportable_fields
    fields.map(&:first).sort.delete_if do |f|
      f.match(/access|permission|permitted_user_ids|tracker_ids/)
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias :name :full_name

  def promote!( account_name, options = {} )
    @recently_converted = true
    if !self.email.blank? and (contact = Contact.where(:email => self.email).first)
      I18n.locale_around(:en) { update_attributes :status => 'Converted', :contact_id => contact.id }
      if contact.account.blank? && !account_name.blank?
        account = Account.find_or_create_for(self, account_name, options)
        contact.update_attributes :account => account if account.valid?
      end
    else
      account = Account.find_or_create_for(self, account_name, options)
      contact = Contact.create_for(self, account)
      if [account, contact].all?(&:valid?)
        I18n.locale_around(:en) { update_attributes :status => 'Converted', :contact_id => contact.id }
      end
    end
    return account || contact.account, contact
  end

  def reject!
    @recently_rejected = true
    I18n.locale_around(:en) { update_attributes :status => 'Rejected' }
  end

  def deliminated( deliminator, fields )
    fields.map { |field| self.send(field) }.join(deliminator)
  end

  def assigned_to?( user )
    assignee_id == user.id
  end

  def reassigned?
    !assignee.blank? && ((@recently_changed.include?('assignee_id') && !@recently_created) ||
                         @recently_created && assignee_id != user_id)
  end

protected
  def set_recently_created
    @recently_created = true
  end

  def notify_assignee
    UserMailer.delay.lead_assignment_notification(self) if reassigned? && !self.do_not_notify
  end

  def set_initial_state
    I18n.locale_around(:en) { self.status = 'New' unless self.status } if self.new_record?
  end

  def log_update
    return if @do_not_log
    case
    when @recently_converted then Activity.log(updater_or_user, self, 'Converted')
    when @recently_rejected then Activity.log(updater_or_user, self, 'Rejected')
    when @recently_destroyed then Activity.log(updater_or_user, self, 'Deleted')
    when @recently_restored then Activity.log(updater_or_user, self, 'Restored')
    else
      Activity.log(updater_or_user, self, 'Updated')
    end
  end

  def set_identifier
    self.identifier = Identifier.next_lead
  end

  def log_recently_changed
    @recently_changed = changed
  end
end
