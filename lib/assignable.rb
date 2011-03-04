module Assignable
  extend ActiveSupport::Concern

  included do
    belongs_to :assignee, :model => 'User', :required => false
  end

  module ClassMethods
    def assigned_to(user_or_user_id)
      case user_or_user_id
      when DataMapper::Resource
        all(:assignee => user_or_user_id)
      else
        all(:assignee_id => user_or_user_id)
      end
    end
  end

  def assigned_to?( user )
    assignee_id == user.id
  end

end
