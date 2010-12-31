module Activities
  extend ActiveSupport::Concern

  included do
    has n, :activities, :as => :subject# , :dependent => :destroy

    after :create, :log_creation
    after :update, :log_update

    belongs_to :updater, model: 'User', required: false

    attr_accessor :do_not_log
  end

  def log_creation
    return if self.do_not_log
    Activity.log(self.user, self, 'Created')
    @recently_created = true
  end

  def updater_or_user
    self.updater.nil? ? self.user : self.updater
  end

  def log_update
    return if self.do_not_log
    case
    when changed.include?('deleted_at') && deleted_at
      Activity.log(updater_or_user, self, 'Deleted')
    when changed.include?('deleted_at') && !deleted_at
      Activity.log(updater_or_user, self, 'Restored')
    else
      Activity.log(updater_or_user, self, 'Updated')
    end
  end

  def related_activities
    @activities ||= Activity.any_of(
      { :subject_type => %w(Lead Account Contact), :subject_id => self.id },
      { :subject_type => %w(Comment Email), :subject_id => comments.map(&:id) },
      { :subject_type => 'Task', :subject_id => tasks.map(&:id) }
    ).all(:order => :updated_at.desc)

    if self.respond_to?(:contacts)
      @activities = @activities.any_of(
        { :subject_type => 'Contact', :subject_id => contacts.map(&:id) },
        { :subject_type => 'Lead',
          :subject_id => leads.flatten.map(&:id) },
        { :subject_type => 'Task',
          :subject_id => contacts.map(&:tasks).flatten.map(&:id) +
          contacts.map(&:leads).flatten.map(&:tasks).flatten.map(&:id) },
        { :subject_type => %w(Comment Email),
          :subject_id => contacts.map(&:comments).flatten.map(&:id) +
          contacts.map(&:emails).flatten.map(&:id) +
          leads.map(&:comments).flatten.map(&:id) +
          leads.map(&:emails).flatten.map(&:id) })
    end
    @activities
  end
end
