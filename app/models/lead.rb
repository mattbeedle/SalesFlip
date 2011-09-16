class Lead
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include ParanoidDelete
  include Trackable
  include Activities
  include Sunspot::DataMapper
  include Assignable
  include Gravtastic
  include ActiveModel::Observing
  include OnlineFields

  extend SimilarTo

  is_gravtastic

  clean_attributes :company, :first_name, :last_name,
    :email, :phone, :website

  property :id, Serial
  property :first_name, String
  property :last_name, String, :required => true
  property :email, String
  property :phone, String
  property :rating, Integer
  property :notes, Text

  has_constant :titles,         lambda { I18n.t(:titles) }
  has_constant :salutations,    lambda { I18n.t(:salutations) }
  has_constant :statuses,       I18n.t(:lead_statuses, :locale => :en)
  has_constant :sources,        lambda { I18n.t(:lead_sources) }
  has_constant :company_sizes,  lambda { I18n.t(:company_sizes) }

  property :company, String
  property :company_phone, String
  property :company_blog, String
  property :company_facebook, String
  property :company_twitter, String
  property :career_site, Text
  property :job_title, String
  property :department, String
  property :alternative_email, String
  property :fax, String
  property :mobile, String
  property :address, Text
  property :city, String
  property :postal_code, String
  property :country, String
  property :referred_by, String
  property :do_not_call, Boolean
  property :industry, String
  property :duplicate, Boolean

  property :homepage, String
  property :identifier, Integer
  property :created_at, DateTime, :index => true
  property :created_on, Date
  property :updated_at, DateTime, :index => true
  property :updated_on, Date

  attr_accessor :do_not_notify, :do_not_index, :duplicate_check

  belongs_to   :user, :required => true
  belongs_to   :assignee, :model => 'User', :required => false
  belongs_to   :contact, :required => false
  belongs_to   :campaign, :required => false
  has n, :comments, :as => :commentable#, :dependent => :delete_all
  has n, :tasks, :as => :asset#, :dependent => :delete_all
  has n, :emails, :as => :commentable#, :dependent => :delete_all

  validates_presence_of :salutation, :phone, :job_title, :email,
    :if => lambda { |l| l.status_is?('Converted') }

  validates_with_block :company do
    if duplicate_check
      if similar.any? || similar_accounts.any?
        return [false, 'This lead is a duplicate']
      end
    end
    true
  end

  before :valid?, :set_initial_state
  before :create,     :set_identifier
  before :create,     :set_recently_created
  before :save,       :log_recently_changed
  after  :save do
    notify_assignee unless do_not_notify
  end
  after :save do
    tasks.update! :asset_updated_at => updated_at
  end

  def self.update_from_csv_line(csv, deliminator)
    headings = nil
    CSV.read(csv).each_with_index do |values, index|
      if index == 0
        headings = values
      else
        puts values.join(',')
        lead = Lead.find(values.first) rescue nil
        lead.update_from_csv(values, headings) if lead
      end
    end
  end

  def update_from_csv(values, headings)
    values.each_with_index do |value, index|
      send("#{headings[index].downcase.gsub(/\s/, '_')}=", value)
    end
  end

  def self.unassigned
    all(assignee_id: nil)
  end

  def self.for_company(company)
    all(user_id: company.users.map(&:id))
  end

  def self.converted
    status_is('Converted')
  end

  def self.in_campaign(id)
    all(campaign_id: id)
  end

  def self.reserve_for(user)
    id = repository.adapter.select(<<-SQL, user.id)
    update leads set assignee_id = ?
    where
      id = (
        select id from leads
        where
          assignee_id is null and
          status = #{status.flag_map.invert["New"]} and
          deleted_at is null and
          (source is null OR source <> #{source.flag_map.invert["Website"]})
        order by created_at desc
        limit 1
      )
    returning id
    SQL

    Lead.get(id)
  end

  searchable do
    text :first_name, :last_name, :email, :phone, :notes, :company,
      :alternative_email, :mobile, :address, :referred_by, :website, :twitter,
      :linked_in, :facebook, :xing
  end

  def self.with_status( statuses )
    statuses = statuses.lines if statuses.respond_to?(:lines)
    all(:status => statuses)
  end

  def self.exportable_fields
    properties.map { |p| p.name.to_s }.sort.delete_if do |f|
      f.match(/access|tracker_ids/)
    end
  end

  # @return [Array<Lead>] all potentially similar leads
  def similar
    Lead.all.similar_to(self)
  end

  # @return [Array<Account>] all potentially similar accounts
  def similar_accounts
    Account.all.similar_to(self)
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias :name :full_name

  def promote!( account_name, options = {} )
    @recently_converted = true
    if email.present? && (contact = Contact.first(:email => email))
      self.attributes = { :status => 'Converted', :contact_id => contact.id }
      opportunity = Opportunity.create_for(contact, options)
      if !opportunity.new_record? && opportunity.reload.valid?
        contact.update_attributes salutation: salutation, last_name: last_name,
          email: email, job_title: job_title, phone: phone
        save
        if contact.account.blank? && !account_name.blank?
          account = Account.find_or_create_for(self, account_name, options)
          contact.update :account => account if account.valid?
        end
      else
        return contact.account, contact, opportunity.reload
      end
    else
      opportunity = Opportunity.new(
        options[:opportunity].merge(contact: Contact.new, user: user))
      if opportunity.valid?
        account = Account.find_or_create_for(self, account_name, options)
        contact = Contact.create_for(self, account, options)
        opportunity = Opportunity.create_for(contact, options)
      else
        account = Account.new(name: account_name)
        contact = account.contacts.build
      end

      [account, contact, opportunity].each(&:valid?)

      if [account, contact, opportunity].all?(&:valid?)
        self.attributes = { status: 'Converted', contact_id: contact.id }
        save
      end
    end
    return contact.account || account, contact, opportunity.reload
  end

  def reject!(attributes = {})
    @recently_rejected = true
    update attributes.merge(:status => 'Rejected')
  end

  def deliminated( deliminator, fields )
    fields.map { |field| "\"#{self.send(field)}\"" }.join(deliminator)
  end

  def reassigned?
    @reassigned = assignee && (
      @recently_changed && @recently_changed.include?('assignee_id') ||
      @recently_created && assignee_id != user_id
    )
  end

protected
  def set_recently_created
    @recently_created = true
  end

  def notify_assignee
    if reassigned? && !do_not_notify
      Resque.enqueue(UserMailerJob, self.id)
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

  def log_recently_changed
    @recently_changed = changed.dup
  end

private
  def maybe_auto_index
    unless self.do_not_index || self.deleted_at
      if @marked_for_auto_indexing
        async(:solr_index!)
        remove_instance_variable(:@marked_for_auto_indexing)
      end
    end
  end
end
