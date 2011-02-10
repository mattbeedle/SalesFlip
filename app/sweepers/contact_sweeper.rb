class ContactSweeper < ActionController::Caching::Sweeper
  observe Contact

  sweeper = instance

  after :create do |contact|
    sweeper.expire_cache_for(contact)
  end

  after :update do |contact|
    sweeper.expire_cache_for(contact)
  end

  after :destroy do |contact|
    sweeper.expire_cache_for(contact)
    sweeper.expire_fragment('deleted_items_nav_link-true')
    sweeper.expire_fragment('deleted_items_nav_link-false')
  end

  def expire_cache_for(contact)
    expire_fragment("contact_partial-#{contact.id}")
    expire_fragment("contact_with_assets-#{contact.id}")
    contact.tasks.each do |task|
      expire_fragment("task_partial-#{task.id}-true")
      expire_fragment("task_partial-#{task.id}-false")
    end
    unless contact.account.blank? || contact.account.new_record?
      account = contact.account
      expire_fragment("account_partial-#{account.id}")
    end
  rescue
    nil
  end
end
