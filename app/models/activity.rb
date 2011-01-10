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
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  has n, :activity_users
  has n, :notified_users, User, through: Resource

  belongs_to :user
  belongs_to :subject, polymorphic: true, required: true

  has_constant :actions, lambda { I18n.t(:activity_actions) }

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
    if %w(Created Deleted).include?(action)
      create_activity(user, subject, action)
    else
      update_activity(user, subject, action)
    end
  end

  def self.create_activity( user, subject, action )
    unless subject.is_a?(Task) and action == 'Viewed'
      Activity.create user: user, action: action, subject: subject
    end
  end

  def self.update_activity( user, subject, action )
    activity = subject.activities.first(:user => user, :action => action)

    if activity
      activity.update(:updated_at => Time.zone.now, :user => user)
    else
      activity = create_activity(user, subject, action)
    end
    activity
  end

  def notified_user_ids=(notified_user_ids)
    notified_users.replace(User.all(id: notified_user_ids))
  end

  def notified_user_ids
    notified_users.map &:id
  end

  class << self
    def visible_to(user)
      all.to_a.delete_if do |activity|
        (activity.subject.permission_is?('Private') && activity.subject.user != user) ||
        (activity.subject.permission_is?('Shared') &&
        !activity.subject.permitted_user_ids.include?(user.id) &&
        activity.subject.user != user)
      end
    end

    def not_restored
      all.to_a.delete_if { |activity| activity.subject.deleted_at.nil? }
    end
  end
end
