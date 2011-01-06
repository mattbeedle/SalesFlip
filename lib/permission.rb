module Permission
  extend ActiveSupport::Concern

  included do
    field :permission,          :type => Integer, :default => 0
    field :permitted_user_ids,  :type => Array,   :default => []

    def self.permitted_for(user)
      if user.role_is?('Freelancer')
        any_of({ :user_id => user.id },
               { :assignee_id => user.id },
               { :permission => Contact.permissions.index('Shared'),
                 :permitted_user_ids.in => [user.id] })
      else
        any_of({ :user_id => user.id },
               { :permission => Contact.permissions.index('Public') },
               { :assignee_id => user.id },
               { :permission => Contact.permissions.index('Shared'),
                 :permitted_user_ids.in => [user.id] })
      end
    end

    validates_presence_of :permission
    validate :require_permitted_users

    has_constant :permissions, lambda { I18n.t(:permissions) }
  end

  def require_permitted_users
    if I18n.locale_around(:en) { permission_is?('Shared') } and permitted_user_ids.blank?
      errors.add :permitted_user_ids, I18n.t('activerecord.errors.messages.blank')
    end
  end

  def permitted_for?( user )
    I18n.locale_around(:en) do
      if !user.role_is?('Freelancer')
        user_id == user.id || permission == 'Public' || assignee_id == user.id ||
          (permission == 'Shared' && permitted_user_ids.include?(user.id)) ||
          (permission == 'Private' && assignee_id == user.id)
      else
        user_id == user.id || (assignee_id == user.id && permission == 'Public') ||
          (assignee_id == user.id && permission == 'Private') ||
          (permission == 'Shared' && permitted_user_ids.include?(user.id) && assignee_id == user.id)
      end
    end
  end
end
