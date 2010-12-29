module Activities
  extend ActiveSupport::Concern

  included do
    # has n, :activities,
      # child_key: [ :subject_id ],
      # dependent: :destroy,
      # subject_type: self

    has n, :activities, :as => :subject, :suffix => :type# , :dependent => :destroy

    after :create, :log_creation
    after :update, :log_update

    belongs_to :updater, :model => 'User', :required => false

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
    when @recently_destroyed
      Activity.log(updater_or_user, self, 'Deleted')
    when @recently_restored
      Activity.log(updater_or_user, self, 'Restored')
    else
      Activity.log(updater_or_user, self, 'Updated')
    end
  end

  def related_activities
    @activities ||=
      Activity.any_of({ :subject_type => %w(Lead Account Contact), :subject_id => self.id },
                      { :subject_type => %w(Comment Email), :subject_id => comments.map(&:id) },
                      { :subject_type => 'Task', :subject_id => tasks.map(&:id) }).all(:order => :updated_at.desc)
    if self.respond_to?(:contacts)
      @activities = @activities.any_of(
        { :subject_type => 'Contact', :subject_id => self.contacts.map(&:id) },
        { :subject_type => 'Lead',
          :subject_id => self.leads.flatten.map(&:id) },
        { :subject_type => 'Task',
          :subject_id => self.contacts.map(&:tasks).flatten.map(&:id) +
          self.contacts.map(&:leads).flatten.map(&:tasks).flatten.map(&:id) },
        { :subject_type => %w(Comment Email),
          :subject_id => self.contacts.map(&:comments).flatten.map(&:id) +
          self.contacts.map(&:emails).flatten.map(&:id) +
          self.leads.map(&:comments).flatten.map(&:id) +
          self.leads.map(&:emails).flatten.map(&:id) })
    end
    @activities
  end
end
