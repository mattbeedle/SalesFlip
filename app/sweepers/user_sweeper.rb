class UserSweeper < ActionController::Caching::Sweeper
  observe User

  def after_update(user)
    expire_cache_for(user)
  end

  def after_destroy(user)
    expire_cache_for(user)
  end

protected
  def expire_cache_for(user)
    user.comments.each do |comment|
      expire_fragment("comment_partial-#{comment.id}")
    end if user.previous_changes.keys.include?('email')
  end
end
