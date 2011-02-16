class Account

  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include ParanoidDelete
  include Permission
  include Trackable
  include Activities
  include Sunspot::DataMapper
  include Assignable
  include ActiveModel::Observing
  include OnlineFields

  property :id, Serial
  property :name, String, required: true
  property :email, String, allow_blank: true
  property :phone, String
  property :fax, String
  property :billing_address, Text
  property :shipping_address, Text
  property :identifier, Integer
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date
  property :access, Integer

  has_constant :account_types, lambda { I18n.t(:account_types) }

  belongs_to :user, required: true
  belongs_to :parent, model: 'Account', required: false

  validates_uniqueness_of :email, allow_blank: true

  has n,   :contacts#, :dependent => :nullify
  has n,   :leads, :through => :contacts
  has n,   :tasks, :as => :asset
  has n,   :comments, :as => :commentable
  has n,   :emails, :as => :commentable
  has n,   :children, :model => 'Account', :child_key => 'parent_id'

  before :create,     :set_identifier

  def self.for_company(company)
    all(:user_id => company.users.map(&:id))
  end

  def self.unassigned
    all(:assignee_id => nil)
  end

  def self.name_like(name)
    all(:name => /#{name}/i)
  end

  searchable do
    text :name, :email, :phone, :website, :fax
  end

  def self.for_company(company)
    where(:user_id => company.users.map(&:id))
  end

  def self.assigned_to(user_or_user_id)
    user_id = DataMapper::Resource === user_or_user_id ? user_or_user_id.id : user_or_user_id
    all(assignee_id: user_id) | all(user_id: user_id, assignee_id: nil)
  end

  def self.similar_accounts( name )
    Account.all(:fields => [:id, :name]).select do |account|
      name.levenshtein_similar(account.name) > 0.5
    end
  end

  def self.exportable_fields
    properties.map { |p| p.name.to_s }.sort.delete_if do |f|
      f.match(/access|permission|permitted_user_ids|tracker_ids/)
    end
  end

  alias :full_name :name

  def website=( website )
    website = "http://#{website}" if !website.nil? and !website.match(/^http:\/\//)
    attribute_set :website, website
  end

  def self.find_or_create_for( object, name_or_id, options = {} )
    account = Account.get name_or_id
    account ||= Account.first(:name => name_or_id)
    account ||= create_for(object, name_or_id, options)
    account
  end

  def self.create_for( object, name, options = {} )
    if options[:permission] == 'Object'
      permission = object.permission
      permitted = object.permitted_user_ids
    else
      permission = options[:permission] || 'Public'
      permitted = options[:permitted_user_ids]
    end
    account = object.updater_or_user.accounts.build :permission => permission,
      :name => name, :permitted_user_ids => permitted,
      :account_type => Account.account_types[I18n.in_locale(:en) { Account.account_types.index('Prospect') }]
    account.save unless options[:just_validate] == true
    account
  end

  def deliminated( deliminator, fields )
    fields.map { |field| self.send(field) }.join(deliminator)
  end

  def set_identifier
    self.identifier = Identifier.next_account
  end

end
