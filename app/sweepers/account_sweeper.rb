class AccountSweeper < ActionController::Caching::Sweeper
  observe Account

  # The callbacks from the observer are instance_eval'd against the model, so
  # we don't get access to methods defined on the sweeper. Therefore, we
  # capture the singleton instance of the sweeper and call the expiration
  # methods directly on it.
  sweeper = instance

  after :update do |account|
    sweeper.expire_cache_for(account)
  end

  after :destroy do |account|
    sweeper.expire_cache_for(account)
    sweeper.expire_fragment('deleted_items_nav_link-true')
    sweeper.expire_fragment('deleted_items_nav_link-false')
  end

  def expire_cache_for(account)
    expire_fragment("account_partial-#{account.id}")
    account.contacts.each do |contact|
      expire_fragment("contact_partial-#{contact.id}")
      expire_fragment("contact_with_assets-#{contact.id}")
    end
  end
end
