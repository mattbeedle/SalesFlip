class Campaign
  include DataMapper::Resource
  include DataMapper::Timestamps
  include ParanoidDelete
  include Activities

  property :id, Serial
  property :name, String
  property :start_date, Date
  property :end_date, Date
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name

  belongs_to :user, required: false
  has 1, :objective

  accepts_nested_attributes_for :objective

  validates_with_block :objective do
    if objective
      objective.valid? || [false, objective.errors.to_hash]
    else
      true
    end
  end

  has n, :leads
  has n, :tasks, :as => :asset
  has n, :comments, :as => :commentable

  after :save do
    tasks.update! :asset_updated_at => updated_at
  end

  def self.assigned_to(user)
    all("leads.assignee_id" => user.id, :unique => true)
  end

  def start_date?
    start_date.present?
  end

  def end_date?
    end_date.present?
  end

  def objective?
    objective && objective.number_of_leads.present?
  end

  def related_activities
    tasks.activities | comments.activities | leads.activities | activities
  end

end
