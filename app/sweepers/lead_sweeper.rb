class LeadSweeper < ActionController::Caching::Sweeper
  observe Lead

  def after_update(lead)
    expire_cache_for(lead)
  end

  def after_create(lead)
    expire_cache_for(lead)
  end

  private
  def expire_cache_for(lead)
    expire_fragment("lead_partial-#{lead.id}")
    expire_fragment("lead_show-#{lead.id}")
    lead.tasks.each do |task|
      expire_fragment("task_partial-#{task.id}")
    end
    unless lead.contact.blank? || lead.contact.new_record?
      contact = lead.contact
      expire_fragment("contact_partial-#{contact.id}")
      expire_fragment("contact_show-#{contact.id}")
      expire_fragment("contact_with_assets-#{contact.id}")
      unless contact.account.blank? || contact.account.new_record?
        account = contact.account
        expire_fragment("account_partial-#{account.id}")
        expire_fragment("account_show-#{account.id}")
      end
    end
  rescue
    nil
  end
end
