class Activity
  include DataMapper::Resource
  include DataMapper::Timestamps
  include HasConstant::Orm::DataMapper

  property :id, Serial
  property :info, String
  property :notified_user_ids, Object, :default => []

  property :subject_id, Integer, required: true
  property :subject_type, String, required: true

  belongs_to :user, :required => true

  def subject
    subject_type.constantize.get(subject_id) if subject_type
  end

  def subject=(new_subject)
    if new_subject
      self.attributes = {subject_id: new_subject.id, subject_type: new_subject.class}
    else
      self.attributes = {subject_id: nil, subject_type: nil}
    end
  end

  def self.for_subject(subject)
    all(:subject_id => subject.id, :subject_type => subject.class.to_s)
  end

  def self.already_notified(user)
    all(:notified_user_ids => user.id)
  end

  def self.not_notified(user)
    all(:notified_user_ids.ne => user.id)
  end

  has_constant :actions, lambda { I18n.t(:activity_actions) }

  def self.log( user, subject, action )
    if %w(Created Deleted).include?(action)
      create_activity(user, subject, action)
    else
      update_activity(user, subject, action)
    end
  end

  def self.create_activity( user, subject, action )
    unless subject.is_a?(Task) and action == 'Viewed'
      Activity.create :subject => subject, :action => action, :user => user
    end
  end

  def self.update_activity( user, subject, action )
    activity = Activity.where(:user_id => user.id, :subject_id => subject.id,
                              :subject_type => subject.class.name,
                              :action => Activity.actions.index(action)).first
    if activity
      activity.update(:updated_at => Time.zone.now, :user_id => user.id)
    else
      create_activity(user, subject, action)
    end
    activity
  end

  class << self
    def visible_to(user)
      where.to_a.delete_if do |activity|
        begin
          (activity.subject.permission_is?('Private') && activity.subject.user != user) ||
          (activity.subject.permission_is?('Shared') &&
          !activity.subject.permitted_user_ids.include?(user.id) &&
          activity.subject.user != user)
        rescue StandardError => e
          true
        end
      end
    end

    def not_restored
      where.to_a.delete_if { |activity| activity.subject.deleted_at.nil? }
    end
  end
end
