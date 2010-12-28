class Account

  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include ParanoidDelete
  include Permission
  include Trackable
  include Activities
  # include Sunspot::Mongoid
  include Assignable

  property :id, Serial
  property :name, String, :required => true
  property :email, String, :unique => true, :allow_blank => true
  property :website, String
  property :phone, String
  property :fax, String
  property :facebook, String
  property :linked_in, String
  property :twitter, String
  property :xing, String
  property :billing_address, String
  property :shipping_address, String
  
  has_constant :accesses, lambda { I18n.t(:access_levels) }
  has_constant :account_types, lambda { I18n.t(:account_types) }

  belongs_to :user, required: false
  belongs_to :parent, model: 'Account', required: false
  
  has n,   :contacts#, :dependent => :nullify
  has n,   :tasks, :as => :asset, :suffix => :type
  has n,   :comments, :as => :commentable, :suffix => :type
  has n,   :children, :model => 'Account', :child_key => 'parent_id'

  def self.for_company(company)
    all(:user_id => company.users.map(&:id))
  end

  def self.unassigned
    all(:assignee_id => nil)
  end

  def self.name_like(name)
    all(:name => /#{name}/i)
  end

  # searchable do
    # text :name, :email, :phone, :website, :fax
  # end

  def self.assigned_to( user_id )
    all ["assignee_id = ? OR (user_id = ? and assignee_id is null)", user_id, user_id]
  end
  
  def self.similar_accounts( name )
    ids = Account.only(:id, :name).map do |account|
      [account.id, name.levenshtein_similar(account.name)]
    end.select { |similarity| similarity.last > 0.5 }.map(&:first)
    Account.all(:_id => ids)
  end

  def self.exportable_fields
    fields.map(&:first).sort.delete_if do |f|
      f.match(/access|permission|permitted_user_ids|tracker_ids/)
    end
  end

  def leads
    @leads ||= contacts.map(&:leads).flatten
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
      permission = options[:permission] || 0
      permitted = options[:permitted_user_ids]
    end
    account = object.updater_or_user.accounts.create :permission => permission,
      :name => name, :permitted_user_ids => permitted, :account_type => 'Prospect'
  end

  def deliminated( deliminator, fields )
    fields.map { |field| self.send(field) }.join(deliminator)
  end

end
