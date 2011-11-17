class Contact
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
  include Exportable

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
  after :save do
    tasks.update! :asset_updated_at => updated_at
  end

  has_constant :accesses,     lambda { I18n.t(:access_levels) }
  has_constant :titles,       lambda { I18n.t(:titles) }
  has_constant :sources,      lambda { I18n.t(:lead_sources) }
  has_constant :salutations,  lambda { I18n.t(:salutations) }

  belongs_to :account, :required => false
  belongs_to :user, :required => true
  belongs_to :lead, :required => false

  has n, :tasks, :as => :asset#, :dependent => :destroy
  has n, :comments, :as => :commentable#, :dependent => :delete_all
  has n, :leads#, :dependent => :destroy
  has n, :emails, :as => :commentable#, :dependent => :delete_all
  has n, :opportunities#, :dependent => :destroy

  def company_name
    account.name if account
  end

  def next_task_date
    tasks.desc(:due_at).first.try(:due_at)
  end

  def last_comment_date
    comments.desc(:created_at).first.try(:created_at)
  end

  def self.for_company(company)
    all(user_id: company.users.map(&:id))
  end

  def self.name_like(name)
    all(full_name: /#{name}/i)
  end

  searchable do
    text :first_name, :last_name, :department, :email, :alt_email, :phone, :mobile,
      :fax, :website, :linked_in, :facebook, :twitter, :xing, :address
    text :account do
      account.try(:name)
    end
  end

  def self.exportable_fields
    properties.map { |p| p.name.to_s }.sort.delete_if do |f|
      f.match(/access|tracker_ids/)
    end
  end

  # @return all comments for this contact, including comments on this contact's
  # leads.
  def comments_including_leads
    if leads.any?
      # It's important that we only run this line if the contact has leads,
      # otherwise the scope gets corrupted, returning ALL comments.
      comments | leads.comments
    else
      comments
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias :name :full_name

  def listing_name
    "#{last_name}, #{first_name}".strip.gsub(/,$/, '')
  end

  def self.create_for( lead, account, options = {} )
    contact = account.contacts.new :user => lead.updater_or_user

    lead.attributes.each do |key, value|
      next if %w(identifier id user_id _sphinx_id created_at updated_at deleted_at tracker_ids updater_id).include?(key.to_s)
      if contact.respond_to?("#{key}=")
        contact.send("#{key}=", value)
      end
    end

    if account.valid? && contact.valid? && !options[:just_validate]
      contact.save
      contact.leads << lead
    end
    contact
  end

  def deliminated( deliminator, fields )
    fields.map { |field| "\"#{self.send(field)}\"" }.join(deliminator)
  end

protected
  def set_identifier
    self.identifier = Identifier.next_contact
  end

  def set_full_name
    attribute_set :full_name, "#{first_name} #{last_name}"
  end
end
