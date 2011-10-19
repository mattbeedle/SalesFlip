class PagesController < ApplicationController

  before_filter :find_activities, :only => [ :index ]
  before_filter :find_tasks,      :only => [ :index ], :if => :current_user

protected
  def find_activities
    @activities ||= I18n.in_locale(:en) { Activity.action_is_not('Viewed') }.
      desc(:created_at).limit(20).visible_to(current_user).
      where(creator_id: current_user.company.users.map(&:id))
  end

  def find_tasks
    @overdue ||= Task.for(current_user).incomplete.overdue.desc(:due_at)
    @due_today ||= Task.for(current_user).incomplete.due_today.desc(:due_at)
  end
end
