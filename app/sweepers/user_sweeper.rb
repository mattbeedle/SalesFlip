class UserSweeper < ActionController::Caching::Sweeper
  observe User

  sweeper = instance

  after :update do |user|
    sweeper.expire_cache_for(user)
  end

  after :destroy do |user|
    sweeper.expire_cache_for(user)
  end

  def expire_cache_for(user)
    user.comments.each do |comment|
      expire_fragment("comment_partial-#{comment.id}")
    end if user.changed.include?('email')
  end
end
