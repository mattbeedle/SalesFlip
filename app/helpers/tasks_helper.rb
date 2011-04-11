# Methods added to this helper will be available to all templates in the application.
module TasksHelper
  def task_asset_info(task,link=false)
    return if !task.asset || action_is('show')
    a = task.asset
    a_to_dom = a.class.to_s.underscore.downcase
    print =  "<br/><small class='xs'><span class='asset_type "
    print << "#{a_to_dom}'>#{a.class.to_s}: </span>"
    print << link if link
    if a.respond_to?(:company) && a.company.present?
      print << " @ #{a.company}"
    end
    if a.respond_to?(:email) && a.email.present?
      print << " | Email: <a href='mailto:#{a.email}'>#{a.email}</a>"
    end
    if a.respond_to?(:phone) && a.phone.present?
      print << " | Phone: #{a.phone}"
    end
    print << "</small>"
    print.html_safe
  end

  def task_cache_key(task)
    keys = [
      task.id,
      task.updated_at,
      task.asset_id,
      task.asset_updated_at,
      action_is('show'),
      can?(:update, task),
      task.assigned_to?(current_user)
    ]

    "task-#{keys.join("-")}"
  end
end
