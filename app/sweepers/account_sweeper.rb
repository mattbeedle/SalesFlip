class AccountSweeper < ActionController::Caching::Sweeper
  observe Account

  def after_update(account)
    expire_cache_for(account)
  end

  def after_destroy(account)
    expire_cache_for(account)
  end

  private
  def expire_cache_for(account)
    expire_fragment("account_partial-#{account.id}")
    expire_fragment("account_show-#{account.id}")
    account.contacts.each do |contact|
      expire_fragment("contact_partial-#{contact.id}")
      expire_fragment("contact_show-#{contact.id}")
      expire_fragment("contact_with_assets-#{contact.id}")
    end
    account.tasks.each do |task|
      expire_fragment("task_partial-#{task.id}")
    end
  end
end
