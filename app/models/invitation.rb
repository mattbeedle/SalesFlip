class Invitation
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper

  property :id, Serial
  property :email, String, :required => true
  property :code, String, :required => true
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  belongs_to :invited, :model => 'User', :required => false
  belongs_to :inviter, :model => 'User', :required => true

  before :valid? do
    generate_code if new?
  end
  after :create, :send_invitation

  has_constant :roles, ROLES,
    required: true, auto_validation: true

  def self.by_company(company)
    all(:inviter_id => company.users.map(&:id))
  end

protected
  def generate_code
    UUID.state_file = false
    self.code = UUID.new.generate if code.blank?
  end

  def send_invitation
    Resque.enqueue(InvitationMailerJob, id)
  end
end
