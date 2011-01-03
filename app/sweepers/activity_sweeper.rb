class ActivitySweeper < ActionController::Caching::Sweeper
  observe Activity

  def after_update(activity)
    expire_fragment("activity-#{activity.id}")
  end
end
