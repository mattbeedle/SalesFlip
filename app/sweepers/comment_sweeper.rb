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
    expire_fragment('deleted_items_nav_link-true')
    expire_fragment('deleted_items_nav_link-false')
  end

  private
  def expire_cache_for(comment)
    expire_fragment("comment_partial-#{comment.id}")
    commentable = comment.commentable
    case
    when commentable.is_a?(Lead)
      expire_fragment("lead_partial-#{commentable.id}")
    when commentable.is_a?(Account)
      expire_fragment("account_partial-#{commentable.id}")
    when commentable.is_a?(Contact)
      expire_fragment("contact_partial-#{commentable.id}")
      expire_fragment("contact_with_assets-#{commentable.id}")
      if !commentable.account.blank? && !commentable.account.new_record?
        expire_fragment("account_partial-#{commentable.account.id}")
      end
    end
  rescue
    nil
  end
end
