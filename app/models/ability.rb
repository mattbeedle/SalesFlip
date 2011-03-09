class Ability
  include CanCan::Ability

  def initialize( user )
    user ||= User.new

    alias_action :view_contact_details, :to => :read

    case user.role
      when "Sales Person", "Key Account Manager", "Freelancer"
        can_manage_assigned(user, Task)
        can_manage_assigned(user, Lead)
        can_manage_assigned(user, Opportunity)
        can_manage_assigned(user, Account)
        can_manage_assigned(user, Contact)

        if user.role == "Freelancer"
          cannot :view_contact_details, contactable_models do |instance|
            !instance.assigned_to?(user)
          end
        end

        can :read, User
        can :update, User do |other_user|
          user == other_user
        end

      when "Service Person"
        can_manage_assigned(user, Task)

        can :manage, [Lead, Account, Contact, Opportunity]

        can :read, User
        can :update, User do |other_user|
          user == other_user
        end

      when "Administrator"
        can :manage, :all

      when nil
        can :create, User
    end
  end

  def can_manage_assigned(user, model)
    can [:create, :read], model
    can [:update, :destroy], model do |instance|
      instance.assigned_to?(user)
    end
  end

  def contactable_models
    [Lead, Opportunity, Account, Contact]
  end
end
