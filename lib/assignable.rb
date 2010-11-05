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
        if respond_to?(:asset) && self.asset && self.asset.respond_to?(:permission)
          if self.asset.permission_is?('Private') && !self.assignee_id.blank? &&
            self.assignee_id != self.user_id
            self.errors.add :base,
              "Cannot assign this task to anyone else because the " +
              "#{self.asset.class.name.downcase} that it is associated " +
                "with is private. Please change the #{self.asset.class.name.downcase} " +
                "permission first"
          elsif self.asset.permission_is?('Shared') && !self.assignee_id.blank? &&
            self.assignee_id != self.user_id &&
            !self.asset.permitted_user_ids.include?(self.assignee_id)
            self.errors.add :base, "Cannot assign this task to #{self.assignee.email} because " +
              "the #{self.asset.class.name.downcase} associated with it is not shared with that user"
          end
        else
          if permission_is?('Private') && !self.assignee_id.blank? &&
            self.assignee_id != self.user_id
            self.errors.add :base, "Cannot assign a private #{self.class.name.to_s.downcase} " +
              "to another user, please change the permissions first"
          elsif permission_is?('Shared') && !self.assignee_id.blank? &&
            !self.permitted_user_ids.include?(self.assignee_id) && self.assignee_id != self.user_id
            self.errors.add :base, "Cannot assign a shared #{self.class.name.to_s.downcase} to " +
              "a user it is not shared with. Please change the permissions first"
          end
        end
      end
    end
  end
end