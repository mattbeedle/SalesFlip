module Assignable
  extend ActiveSupport::Concern

  included do
    belongs_to :assignee, :model => 'User', :required => false

    # We need to default on the property, not on the association, since when
    # setting the assignee_id via a form the assignee association will be
    # blank, and thus over-ride the id specified.
    property :assignee_id, Integer,
      :default => ->(r,_) { r.user_id }
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
    assignee == user
  end

end
