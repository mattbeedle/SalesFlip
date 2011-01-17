class Contact
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
  include ActiveModel::Observing
  is_gravtastic

  property :id, Serial
  property :first_name, String
  property :last_name, String, :required => true
  property :full_name, String
  property :department, String
  property :email, String
  property :alt_email, String
  property :phone, String
  property :mobile, String
  property :fax, String
  property :website, String
  property :blog, String
  property :linked_in, String
  property :facebook, String
  property :twitter, String
  property :xing, String
  property :address, String
  property :born_on, Date
  property :do_not_call, Boolean
  property :identifier, Integer
  property :city, String
  property :country, String
  property :postal_code, String
  property :job_title, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  validates_uniqueness_of :email, allow_blank: true

  before :create, :set_identifier
  before :save,   :set_full_name

  has_constant :accesses,     lambda { I18n.t(:access_levels) }
  has_constant :titles,       lambda { I18n.t(:titles) }
  has_constant :sources,      lambda { I18n.t(:lead_sources) }
  has_constant :salutations,  lambda { I18n.t(:salutations) }

  belongs_to :account, :required => false
  belongs_to :user, :required => true
  belongs_to :assignee, :model => 'User', :required => false
  belongs_to :lead, :required => false

  has n, :tasks, :as => :asset#, :dependent => :destroy
  has n, :comments, :as => :commentable#, :dependent => :delete_all
  has n, :leads#, :dependent => :destroy
  has n, :emails, :as => :commentable#, :dependent => :delete_all
  has n, :opportunities#, :dependent => :destroy

  def self.for_company(company)
    all(:user_id => company.users.map(&:id))
  end

  def self.name_like(name)
    all(:full_name => /#{name}/i)
  end

  searchable do
    text :first_name, :last_name, :department, :email, :alt_email, :phone, :mobile,
      :fax, :website, :linked_in, :facebook, :twitter, :xing, :address
    text :account do
      account.name
    end
  end
  handle_asynchronously :solr_index

  def self.assigned_to( user_id )
    any_of({ :assignee_id => user_id }, { :user_id => user_id, :assignee_id => nil })
  end

  def self.exportable_fields
    properties.map { |p| p.name.to_s }.sort.delete_if do |f|
      f.match(/access|permission|permitted_user_ids|tracker_ids/)
    end
  end

  def comments_including_leads
    comments | leads.comments
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias :name :full_name

  def listing_name
    "#{last_name}, #{first_name}".strip.gsub(/,$/, '')
  end

  def self.create_for( lead, account )
    contact = account.contacts.new :user => lead.updater_or_user, :permission => account.permission,
      :permitted_user_ids => account.permitted_user_ids

    lead.attributes.each do |key, value|
      next if %w(identifier id user_id permission permitted_user_ids _sphinx_id created_at updated_at deleted_at tracker_ids updater_id).include?(key.to_s)
      if contact.respond_to?("#{key}=")
        contact.send("#{key}=", value)
      end
    end

    if account.valid? and contact.valid?
      contact.save
      contact.leads << lead
    end
    contact
  end

  def deliminated( deliminator, fields )
    fields.map { |field| self.send(field) }.join(deliminator)
  end

protected
  def set_identifier
    self.identifier = Identifier.next_contact
  end

  def set_full_name
    attribute_set :full_name, "#{first_name} #{last_name}"
  end
end
