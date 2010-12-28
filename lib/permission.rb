module Permission
  extend ActiveSupport::Concern

  included do
    property :permitted_user_ids, Object, :default => []

    validates_with_method :permitted_user_ids, :method => :require_permitted_users

    has_constant :permissions, I18n.t(:permissions),
      default: 0, required: true
  end

  module ClassMethods

    def permitted_for(user)
      # if !user.role_is?('Freelancer')
        # { :where => {
          # '$where' => "this.user_id == '#{user.id}' || this.permission == '#{Contact.permissions.index('Public')}' || " +
          # "this.assignee_id == '#{user.id}' || " +
          # "(this.permission == '#{Contact.permissions.index('Shared')}' && contains(this.permitted_user_ids, '#{user.id}')) || " +
          # "(this.permission == '#{Contact.permissions.index('Private')}' && this.assignee_id == '#{user.id}')"
        # } }
      # else
        # { :where => {
        # '$where' => "this.user_id == '#{user.id}' || " +
          # "(this.assignee_id == '#{user.id}' && this.permission == '#{Contact.permissions.index('Public')}') || " +
          # "(this.assignee_id == '#{user.id}' && this.permission == '#{Contact.permissions.index('Private')}') || " +
          # "(this.permission == '#{Contact.permissions.index('Shared')}' && contains(this.permitted_user_ids, '#{user.id}'))"
      # } }
      # end
    end

  end

  def permitted_user_ids=( permitted_user_ids )
    unless permitted_user_ids.blank?
      ids = permitted_user_ids.map do |id|
         if id.is_a?(String)
           BSON::ObjectId.from_string(id)
         else
           id
         end
      end.to_a
      attribute_set :permitted_user_ids, ids
    end
  end

  def require_permitted_users
    if I18n.locale_around(:en) { permission_is?('Shared') } and permitted_user_ids.blank?
      [false, I18n.t('activerecord.errors.messages.blank')]
    else
      true
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
