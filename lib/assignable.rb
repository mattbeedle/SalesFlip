module Assignable
  def self.included( base )
    base.class_eval do
      belongs_to_related :assignee, :class_name => 'User'
      
      named_scope :assigned_to, lambda { |user_id| { :where => { :assignee_id => user_id } } }
    end
  end
end