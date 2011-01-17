class Campaign
  include Mongoid::Document
  include ParanoidDelete
  include Activities

  field :name
  field :start_date, :type => Date
  field :end_date, :type => Date

  validates_presence_of :name
  validates_associated :objective

  embeds_one :objective

  belongs_to_related :user, :index => true
  has_many_related :leads, :dependent => :nullify, :index => true do
    def converted
      status_is('Converted')
    end
  end
  has_many_related :tasks, :as => :asset, :dependent => :delete_all, :index => true
  has_many_related :comments, :as => :commentable, :dependent => :delete_all, :index => true

  def objective?
    objective && objective.number_of_leads?
  end

  def permission_is?(permission)
    permission == 'Public'
  end

  def permitted_for?(*)
    true
  end

  def related_activities
    Activity.where(:subject_id => id)
  end

end
