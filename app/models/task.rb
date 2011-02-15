class Task
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include Permission
  include Activities
  include Assignable
  include ActiveModel::Observing

  property :id, Serial
  property :name, Text, :required => true, :lazy => false
  property :due_at, Time, :required => true
  property :priority, Integer
  property :completed_at, Time
  property :deleted_at, Time
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  property :asset_updated_at, DateTime

  has_constant :categories, I18n.t(:task_categories),
    required: true, auto_validation: true

  belongs_to :user, :required => true
  belongs_to :asset, :polymorphic => true, :required => false, suffix: 'type'
  belongs_to :completed_by, :model => 'User', :required => false

  has n, :activities, :as => :subject#, :dependent => :destroy

  before :create, :set_recently_created
  before :save,   :log_recently_changed
  after  :update, :log_reassignment
  after  :create, :assign_unassigned_asset

  after :update,  :log_update
  after :save,    :notify_assignee

  def self.incomplete
    all({ :completed_at => nil })
  end

  def self.for(user)
    any_of({ :user_id => user.id, :assignee_id => user.id }, { :assignee_id => user.id },
           { :user_id => user.id, :assignee_id => nil })
  end

  def self.assigned_by(user)
    all(:user_id => user.id, :assignee_id.not => user.id)
  end

  def self.pending
    all(:completed_at => nil, :assignee_id => nil)
  end

  def self.assigned
    all(:assignee_id.not => nil)
  end

  def self.completed
    all(:completed_at.not => nil)
  end

  def self.overdue
    all(:due_at.lte => Time.zone.now.midnight)
  end

  def self.due_today
    all(:due_at.gt => Time.zone.now.midnight,
        :due_at.lte => Time.zone.now.end_of_day)
  end

  def self.due_tomorrow
    all(:due_at.lte => Time.zone.now.tomorrow.end_of_day,
        :due_at.gte => Time.zone.now.tomorrow.beginning_of_day)
  end

  def self.due_this_week
    all(:due_at.gte => Time.zone.now.tomorrow.beginning_of_day + 1.day,
        :due_at.lte => Time.zone.now.next_week)
  end

  def self.due_next_week
    all(:due_at.gte => Time.zone.now.next_week.beginning_of_week,
        :due_at.lte => Time.zone.now.next_week.end_of_week)
  end

  def self.due_later
    all(:due_at.gt => Time.zone.now.next_week.end_of_week)
  end

  def self.completed_today
    all(:completed_at.gte => Time.zone.now.midnight,
        :completed_at.lte => Time.zone.now.midnight.tomorrow)
  end

  def self.completed_yesterday
    all(:completed_at.gte => Time.zone.now.midnight.yesterday,
        :completed_at.lte => Time.zone.now.midnight)
  end

  def self.completed_last_week
    all(:completed_at.gte => Time.zone.now.beginning_of_week - 7.days,
        :completed_at.lte => Time.zone.now.beginning_of_week)
  end

  def self.completed_this_month
    all(:completed_at.gte => Time.zone.now.beginning_of_month,
        :completed_at.lte => Time.zone.now.beginning_of_week - 7.days)
  end

  def self.completed_last_month
    all(:completed_at.gte => (Time.zone.now.beginning_of_month - 1.day).beginning_of_month,
        :completed_at.lte => Time.zone.now.beginning_of_month)
  end

  def self.daily_email
    (Task.overdue + Task.due_today).flatten.sort_by(&:due_at).group_by(&:user).
      each do |user, tasks|
      TaskMailer.daily_task_summary(user, tasks).deliver
    end
  end

  def self.grouped_by_scope( scopes, options = {} )
    tasks = {}
    scopes.each do |scope|
      if methods(false).include?(scope.to_sym)
        tasks[scope.to_sym] = (options[:target] || self).send(scope.to_sym)
      end
    end
    tasks
  end

  def completed_by_id=( user_id )
    if user_id and not completed?
      @recently_completed = true
      attribute_set :completed_at, Time.zone.now
      attribute_set :completed_by_id, user_id
    end
  end

  def completed?
    completed_at
  end

  def due_at=( due )
    attribute_set :due_at,
      case due
      when 'overdue'
        Time.zone.now.yesterday.end_of_day
      when 'due_today'
        Time.zone.now.end_of_day
      when 'due_tomorrow'
        Time.zone.now.tomorrow.end_of_day
      when 'due_this_week'
        Time.zone.now.end_of_week
      when 'due_next_week'
        Time.zone.now.next_week.end_of_week
      when 'due_later'
        (Time.zone.now.end_of_day + 5.years)
      else
        if !due.is_a?(Time) and Chronic.parse(due)
          Chronic.parse(due)
        else
          due
        end
      end
  end

  def due_at_in_words
    if self.due_at && self.due_at.strftime("%H:%M:%S") == '23:59:59'
      case
      when self.due_at.to_i < Time.zone.now.midnight.to_i
        'overdue'
      when self.due_at.to_i == Time.zone.now.end_of_day.to_i
        'due_today'
      when self.due_at.to_i == Time.zone.now.tomorrow.end_of_day.to_i
        'due_tomorrow'
      when self.due_at.to_i >= (Time.zone.now.tomorrow.end_of_day + 1.day).to_i && self.due_at.to_i <= Time.zone.now.end_of_week.to_i
        'due_this_week'
      when self.due_at.to_i >= Time.zone.now.next_week.beginning_of_week.to_i && self.due_at.to_i <= Time.zone.now.next_week.end_of_week.to_i
        'due_next_week'
      when self.due_at.to_i > Time.zone.now.next_week.end_of_week.to_i
        'due_later'
      end
    elsif self.due_at
      self.due_at.to_s :short
    else
      nil
    end
  end

  def reassigned?
    assignee && (
      @recently_changed && @recently_changed.include?('assignee_id') ||
      @recently_created && assignee_id != user_id
    )
  end

protected
  def set_recently_created
    @recently_created = true
  end

  def log_recently_changed
    @recently_changed = changed.dup
  end

  def assign_unassigned_asset
    if asset && (asset.is_a?(Lead) || asset.is_a?(Opportunity)) && asset.assignee.blank?
      asset.update :assignee => self.user, :do_not_notify => true
    end
  end

  def notify_assignee
    Resque.enqueue(TaskMailerJob, id) if reassigned?
  end

  def log_update
    unless reassigned?
      Activity.log(self.user, self, 'Updated') unless @recently_completed
      Activity.log(self.user, self, 'Completed') if @recently_completed
    end
  end

  def log_reassignment
    Activity.log(self.user, self, 'Re-assigned') if reassigned?
  end
end
