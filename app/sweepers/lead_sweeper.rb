class LeadSweeper < ActionController::Caching::Sweeper
  observe Lead

  sweeper = instance

  after :create do |lead|
    sweeper.expire_cache_for(lead)
  end

  after :update do |lead|
    sweeper.expire_cache_for(lead)
  end

  after :destroy do |lead|
    sweeper.expire_cache_for(lead)
    sweeper.expire_fragment('deleted_items_nav_link-true')
    sweeper.expire_fragment('deleted_items_nav_link-false')
  end

  def expire_cache_for(lead)
    expire_fragment("lead_partial-#{lead.id}")
    lead.tasks.each do |task|
      expire_fragment("task_partial-#{task.id}-true")
      expire_fragment("task_partial-#{task.id}-false")
    end
    unless lead.contact.blank? || lead.contact.new_record?
      contact = lead.contact
      expire_fragment("contact_partial-#{contact.id}")
      expire_fragment("contact_with_assets-#{contact.id}")
      unless contact.account.blank? || contact.account.new_record?
        account = contact.account
        expire_fragment("account_partial-#{account.id}")
      end
    end
  rescue
    nil
  end
end
