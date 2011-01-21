module Activities
  extend ActiveSupport::Concern

  included do
    has n, :activities, :as => :subject# , :dependent => :destroy

    after :create, :log_creation
    after :update, :log_update

    belongs_to :updater, model: 'User', required: false

    unless ParanoidDelete > self
      before :destroy do
        activities.destroy!
      end
    end

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
    # NOTE: the order here is important. If self.activities comes first
    # DataMapper will attempt to reset the foreign keys on the returned
    # activities.
    activities = comments.activities | tasks.activities | self.activities

    if self.respond_to?(:contacts)
      activities |= contacts.activities
      activities |= contacts.leads.activities
      activities |= contacts.tasks.activities
      activities |= contacts.leads.tasks.activities
      activities |= contacts.comments.activities
      activities |= contacts.leads.comments.activities
    end

    activities.all(:order => :updated_at.desc)
  end
end
