class Lead
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include ParanoidDelete
  include Permission
  include Trackable
  include Activities
  include Sunspot::DataMapper
  include Assignable
  include Gravtastic
  is_gravtastic

  property :id, Serial
  property :first_name, String
  property :last_name, String, :required => true
  property :email, String
  property :phone, String
  property :rating, Integer
  property :notes, String

  # has_constant
  # property :title, DataMapper::Property::Enum, :flags => I18n.t(:titles)
  has_constant :titles,       lambda { I18n.t(:titles) }
  # property :salutation, DataMapper::Property::Enum, :flags => I18n.t(:salutations)
  has_constant :salutations,  lambda { I18n.t(:salutations) }
  # property :status, DataMapper::Property::Enum, :flags => I18n.t(:lead_statuses)
  has_constant :statuses,     lambda { I18n.t(:lead_statuses) }
  # property :source, DataMapper::Property::Enum, :flags => I18n.t(:lead_sources)
  has_constant :sources,      lambda { I18n.t(:lead_sources) }

  property :company, String
  property :company_phone, String
  property :company_blog, String
  property :company_facebook, String
  property :company_twitter, String
  property :website, String
  property :career_site, String
  property :job_title, String
  property :department, String
  property :alternative_email, String
  property :fax, String
  property :mobile, String
  property :address, String
  property :city, String
  property :postal_code, String
  property :country, String
  property :referred_by, String
  property :do_not_call, Boolean

  property :twitter, String
  property :linked_in, String
  property :facebook, String
  property :xing, String
  property :identifier, Integer
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  attr_accessor :do_not_notify

  belongs_to   :user, :required => true
  belongs_to   :contact, :required => false
  has n, :comments, :as => :commentable#, :dependent => :delete_all
  has n, :tasks, :as => :asset#, :dependent => :delete_all
  has n, :emails, :as => :commentable#, :dependent => :delete_all

  before :valid?, :set_initial_state
  before :create,     :set_identifier
  before :create,     :set_recently_created
  after  :save do
    notify_assignee unless do_not_notify
  end

  def self.unassigned
    all(:assignee_id => nil)
  end

  def self.for_company(company)
    all(:user_id => company.users.map(&:id))
  end

  searchable do
    text :first_name, :last_name, :email, :phone, :notes, :company, :alternative_email, :mobile,
      :address, :referred_by, :website, :twitter, :linked_in, :facebook, :xing
  end
  # handle_asynchronously :solr_index

  def self.with_status( statuses )
    statuses = statuses.lines if statuses.respond_to?(:lines)
    all(:status => statuses)
  end

  def self.exportable_fields
    properties.map { |p| p.name.to_s }.sort.delete_if do |f|
      f.match(/access|permission|permitted_user_ids|tracker_ids/)
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias :name :full_name

  def promote!( account_name, options = {} )
    @recently_converted = true
    if !self.email.blank? and (contact = Contact.first(:email => self.email))
      self.attributes = {:status => 'Converted', :contact_id => contact.id}
      save
      if contact.account.blank? && !account_name.blank?
        account = Account.find_or_create_for(self, account_name, options)
        contact.update :account => account if account.valid?
      end
    else
      account = Account.find_or_create_for(self, account_name, options)
      contact = Contact.create_for(self, account)
      opportunity = Opportunity.create_for(contact, options)
      if [account, contact].all?(&:valid?)
        self.attributes = {:status => 'Converted', :contact_id => contact.id}
        save
      end
    end
    return account || contact.account, contact, opportunity
  end

  def reject!(attributes = {})
    @recently_rejected = true
    update attributes.merge(:status => 'Rejected')
  end

  def deliminated( deliminator, fields )
    fields.map { |field| self.send(field) }.join(deliminator)
  end

protected
  def set_recently_created
    @recently_created = true
  end

  def notify_assignee
    if assignee && (changed.include?('assignee_id') || @recently_created && assignee_id != user_id)
      UserMailer.lead_assignment_notification(self).deliver
    end
  end

  def set_initial_state
    I18n.locale_around(:en) { self.status = 'New' unless self.status } if self.new?
  end

  def log_update
    return if @do_not_log
    case
    when @recently_converted then Activity.log(updater_or_user, self, 'Converted')
    when @recently_rejected then Activity.log(updater_or_user, self, 'Rejected')
    else
      super
    end
  end

  def set_identifier
    self.identifier = Identifier.next_lead
  end
end
