class TaskSweeper < ActionController::Caching::Sweeper
  observe Task

  def after_update(task)
    expire_cache_for(task)
  end

  def after_destroy(task)
    expire_cache_for(task)
  end

  private
  def expire_cache_for(task)
    expire_fragment("task_partial-#{task.id}")

    asset = task.asset
    case
    when asset.is_a?(Lead)
      expire_fragment("lead_partial-#{asset.id}")
      expire_fragment("lead_show-#{asset.id}")
      unless asset.contact.blank? || asset.contact.new_record?
        expire_contact(asset.contact)
        unless asset.contact.account.blank? || asset.contact.account.new_record?
          expire_account(asset.contact.account)
        end
      end
    when asset.is_a?(Account)
      expire_account(asset)
    when asset.is_a?(Contact)
      expire_contact(asset)
      unless asset.account.blank? || asset.account.new_record?
        expire_account(asset.account)
      end
    end
  rescue
    nil
  end

  def expire_contact(contact)
    expire_fragment("contact_partial-#{asset.id}")
    expire_fragment("contact_show-#{asset.id}")
    expire_fragment("contact_with_assets-#{asset.id}")
  end

  def expire_account(account)
    expire_fragment("account_partial-#{account.id}")
    expire_fragment("account_show-#{account.id}")
  end
end
