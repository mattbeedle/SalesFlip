class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasConstant
  include HasConstant::Orm::Mongoid

  field :email
  field :code
  field :role,   :type => Integer

  belongs_to_related :invited,  :class_name => 'User'
  belongs_to_related :inviter,  :class_name => 'User'

  validates_presence_of :inviter, :email, :code, :role

  before_validation :generate_code, :on => :create
  after_create :send_invitation

  has_constant :roles, ROLES

  named_scope :by_company, lambda { |company| { :where => {
    :inviter_id.in => company.users.map(&:id) } } }

protected
  def generate_code
    UUID.state_file = false
    self.code = UUID.new.generate if code.blank?
  end

  def send_invitation
    InvitationMailer.invitation(self).deliver
  end
end
