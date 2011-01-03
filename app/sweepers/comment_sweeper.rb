class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  def after_create(comment)
    expire_cache_for(comment)
  end

  def after_update(comment)
    expire_cache_for(comment)
  end

  def after_destroy(comment)
    expire_cache_for(comment)
  end

  private
  def expire_cache_for(comment)
    commentable = comment.commentable
    case
    when commentable.is_a?(Lead)
      expire_fragment("lead_partial-#{commentable.id}")
      expire_fragment("lead_show-#{commentable.id}")
    when commentable.is_a?(Account)
      expire_fragment("account_partial-#{commentable.id}")
      expire_fragment("account_show-#{commentable.id}")
    when commentable.is_a?(Contact)
      expire_fragment("contact_partial-#{commentable.id}")
      expire_fragment("contact_partial-#{commentable.id}")
      expire_fragment("contact_with_assets-#{commentable.id}")
      if !commentable.account.blank? && !commentable.account.new_record?
        expire_fragment("account_partial-#{commentable.account.id}")
        expire_fragment("account_show-#{commentable.account.id}")
      end
    end
  rescue
    nil
  end
end
