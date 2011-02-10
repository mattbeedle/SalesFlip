class TaskSweeper < ActionController::Caching::Sweeper
  observe Task

  sweeper = instance

  after :create do |task|
    sweeper.expire_cache_for(task)
  end

  after :update do |task|
    sweeper.expire_cache_for(task)
  end

  after :destroy do |task|
    sweeper.expire_cache_for(task)
    sweeper.expire_fragment('deleted_items_nav_link')
  end

  def expire_cache_for(task)
    expire_fragment("task_partial-#{task.id}-true")
    expire_fragment("task_partial'#{task.id}-false")

    asset = task.asset
    case
    when asset.is_a?(Lead)
      expire_fragment("lead_partial-#{asset.id}")
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
    expire_fragment("contact_with_assets-#{asset.id}")
  end

  def expire_account(account)
    expire_fragment("account_partial-#{account.id}")
  end
end
