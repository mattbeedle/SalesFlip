class AccountSweeper < ActionController::Caching::Sweeper
  observe Account

  def after_update(account)
    expire_cache_for(account)
  end

  def after_destroy(account)
    expire_cache_for(account)
    expire_fragment('deleted_items_nav_link-true')
    expire_fragment('deleted_items_nav_link-false')
  end

  private
  def expire_cache_for(account)
    expire_fragment("account_partial-#{account.id}")
    account.contacts.each do |contact|
      expire_fragment("contact_partial-#{contact.id}")
      expire_fragment("contact_with_assets-#{contact.id}")
    end
    account.tasks.each do |task|
      expire_fragment("task_partial-#{task.id}-true")
      expire_fragment("task_partial-#{task.id}-false")
    end
  end
end
