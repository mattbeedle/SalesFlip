class ActivitySweeper < ActionController::Caching::Sweeper
  observe Activity

  sweeper = instance

  after :update do |activity|
    sweeper.expire_fragment("activity-#{activity.id}")
  end
end
