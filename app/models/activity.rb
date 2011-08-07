class ActivityUser
  include DataMapper::Resource

  belongs_to :notified_user, User, key: true
  belongs_to :activity, key: true
end

class Activity
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper
  include ActiveModel::Observing

  property :id, Serial
  property :info, String
  property :created_at, DateTime, :index => true
  property :updated_at, DateTime, :index => true

  has n, :activity_users
  has n, :notified_users, User, through: Resource

  belongs_to :user, child_key: 'creator_id'
  belongs_to :subject, polymorphic: true, required: true

  has_constant :actions, I18n.t(:activity_actions, :locale => :en), :index => true

  def self.for_subject(subject)
    subject.activities
  end

  def self.already_notified(user)
    all(notified_users.id => user.id)
  end

  def self.not_notified(user)
    all - already_notified(user)
  end

  def self.log( user, subject, action )
    create_activity(user, subject, action)
  end

  def self.create_activity( user, subject, action )
    unless subject.is_a?(Task) and action == 'Viewed'
      Activity.create user: user, action: action, subject: subject
    end
  end

  def notified_user_ids=(notified_user_ids)
    notified_users.replace(User.all(id: notified_user_ids))
  end

  def notified_user_ids
    notified_users.map &:id
  end

  class << self
    def visible_to(user)
      activities = []

      # Ensure that we're using the identity map by using all.each here instead
      # of all.to_a.delete_if.
      all.each do |activity|
        next unless activity.subject

        activities << activity
      end

      activities
    end

    def not_restored
      activities = []

      # Ensure that we're using the identity map by using all.each here instead
      # of all.to_a.delete_if.
      all.each do |activity|
        next if activity.subject.deleted_at.nil?

        activities << activity
      end

      activities
    end
  end

  class Report
    class << self

      # Returns a report of the given user's weekly activity, grouped by the
      # hour the activities were made.
      #
      #   Activity::Report.weekly(user)
      #   # => { "27/06" => { 0 => 10, 2 => 3 } }
      #
      def weekly(user)
        activities = repository.adapter.select(<<-SQL.compress_lines, user.id)
          select
            date_trunc('week', activity_date) as _week,
            to_char(date_trunc('week', activity_date), 'DD/MM') as week,
            date_part('hour', activity_date)::integer as hour,
            count(*) as count
          from
            (
              select id, creator_id, created_at as activity_date from activities
              union
              select id, creator_id, updated_at as activity_date from activities
            ) as activity_dates
          where
            creator_id = ? and
            activity_date >= date_trunc('week', now()) - interval '7 weeks'
          group by _week, week, hour
          order by _week, hour;
        SQL

        # This will allow us to generate a hash like this:
        #
        #   weeks["27/06"][0] = 234
        #   weeks # => { "27/06" => { 0 => 234 } }
        #   weeks["26/06"][1]
        #   weeks # => { "27/06" => { 0 => 234, 1 => 0 } }
        weeks = Hash.new do |h,k|
          h[k] = Hash.new { |h,k| h[k] = 0 }
        end

        activities.each do |activity|
          weeks[activity.week][activity.hour] = activity.count
        end

        weeks
      end

    end
  end
end
