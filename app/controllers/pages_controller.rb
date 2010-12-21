class PagesController < ApplicationController

  before_filter :find_activities, :only => [ :index ]
  before_filter :find_tasks,      :only => [ :index ]

  helper_method :dashboard_cache_key

protected
  def dashboard_cache_key
    "dashboard-#{current_user.id.to_s}-#{Activity.action_is_not('Viewed').count}"
  end

  def find_activities
    unless read_fragment(dashboard_cache_key)
      @activities ||= Activity.action_is_not('Viewed').desc(:created_at).limit(20).
        visible_to(current_user)
    end
  end

  def find_tasks
    unless read_fragment(dashboard_cache_key)
      @overdue ||= Task.for(current_user).incomplete.overdue.desc(:due_at)
      @due_today ||= Task.for(current_user).incomplete.due_today.desc(:due_at)
    end
  end
end
