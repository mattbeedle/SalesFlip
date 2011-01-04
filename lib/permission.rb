module Permission
  extend ActiveSupport::Concern

  included do
    singular_name = name.underscore
    through_relationship_name = :"#{singular_name}_permitted_users"

    through_model = DataMapper::Model.new

    Object.const_set("#{name}PermittedUser", through_model)

    through_model.belongs_to :permitted_user, User, :key => true
    through_model.belongs_to :"#{singular_name}", :key => true

    has n, through_relationship_name
    has n, :permitted_users, User,
      through: through_relationship_name

    validates_presence_of :permitted_users,
      if: lambda {|model| model.permission_is?('Shared')}

    has_constant :permissions, I18n.t(:permissions),
      default: 'Public', required: true, auto_validation: true
  end

  module ClassMethods

    def permitted_for(user)
      scope =  all(user_id: user.id)
      scope |= all(permission: 'Shared', permitted_users.id => user.id)

      if Assignable > self
        scope |= all(assignee_id: user.id)
      end

      unless user.role_is?('Freelancer')
        scope |= all(permission: 'Public')
      end
    end

  end

  def permitted_user_ids=(permitted_user_ids)
    permitted_users.replace(User.all(id: permitted_user_ids))
  end

  def permitted_user_ids
    permitted_users.map &:id
  end

  def permitted_for?(user)
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
