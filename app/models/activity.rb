class Activity
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasConstant

  field :action,            :type => Integer
  field :info
  field :notified_user_ids, :type => Array

  belongs_to_related :user
  belongs_to_related :subject, :polymorphic => true

  validates_presence_of :subject, :user

  named_scope :for_subject, lambda {|model| {
    :where => { :subject_id => model.id, :subject_type => model.class.to_s } } }
  validates_presence_of :subject

  named_scope :already_notified, lambda {|user| {
    :where => { :notified_user_ids => user.id } } }
  named_scope :not_notified, lambda { |user| {
    :where => { :notified_user_ids => { '$ne' => user.id } } } }

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
    activity = Activity.first(:conditions => { :user_id => user.id, :subject_id => subject.id,
                              :subject_type => subject.class.name,
                              :action => Activity.actions.index(action) })
    if activity
      activity.update_attributes(:updated_at => Time.zone.now, :user_id => user.id)
    else
      create_activity(user, subject, action)
    end
    activity
  end
end
