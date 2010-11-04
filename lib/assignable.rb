module Assignable
  def self.included( base )
    base.class_eval do
      belongs_to_related :assignee, :class_name => 'User'
      
      named_scope :assigned_to, lambda { |user_id| { :where => { :assignee_id => user_id } } }
      
      validate :check_permissions
    end
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
    def check_permissions
      if respond_to?(:permission)
        if permission_is?('Private') && !self.assignee_id.blank? &&
          self.assignee_id != self.user_id
          self.errors.add :base,
            "Cannot assign a private #{self.class.name.to_s.downcase} to another user, please change the permissions first"
        elsif permission_is?('Shared') && !self.assignee_id.blank? &&
          !self.permitted_user_ids.include?(self.assignee_id) && self.assignee_id != self.user_id
          self.errors.add :base,
            "Cannot assign a shared #{self.class.name.to_s.downcase} to a user it is not shared with. Please change the permissions first"
        end
      end
    end
  end
end