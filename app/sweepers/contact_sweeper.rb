class ContactSweeper < ActionController::Caching::Sweeper
  observe Contact

  def after_create(contact)
    expire_cache_for(contact)
  end

  def after_update(contact)
    expire_cache_for(contact)
  end

  def after_destroy(contact)
    expire_cache_for(contact)
    expire_fragment('deleted_items_nav_link')
  end

  private
  def expire_cache_for(contact)
    expire_fragment("contact_show-#{contact.id}")
    expire_fragment("contact_partial-#{contact.id}")
    expire_fragment("contact_with_assets-#{contact.id}")
    contact.tasks.each do |task|
      expire_fragment("task_partial-#{task.id}")
    end
    unless contact.account.blank? || contact.account.new_record?
      account = contact.account
      expire_fragment("account_show-#{account.id}")
      expire_fragment("account_partial-#{account.id}")
    end
  rescue
    nil
  end
end
