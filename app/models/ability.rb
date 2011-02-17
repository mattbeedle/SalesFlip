class Ability
  include CanCan::Ability

  def initialize( user )
    user ||= User.new :role => 'Freelancer'

    if user.role_is?('Administrator')
      can :manage, :all
    elsif user.role_is?('Sales Person') || user.role_is?('Service Person') ||
      user.role_is?('Key Account Manager') || user.role_is?('Sales Team Leader')
      can :create, :all
      can :profile, User
      can :read, User
      can :read, Contact
      can :read, Campaign
      can :read, Invitation
      can :manage, Task
      can :read, Search
      can :read, Opportunity do |opportunity|
        opportunity && opportunity.permitted_for?(user)
      end
      can :update, Opportunity do |opportunity|
        opportunity && opportunity.permitted_for?(user)
      end
      can :create, Opportunity
      can :update, Opportunity
      can :next, Lead

      can :view_unassigned, Lead do |lead|
        user.role_is?('Sales Team Leader')
      end

      can :reject, Lead do |lead|
        lead && lead.permitted_for?(user)
      end
      can :convert, Lead do |lead|
        lead && lead.permitted_for?(user)
      end
      can :promote, Lead do |lead|
        lead && lead.permitted_for?(user)
      end
      can :read, Lead do |lead|
        lead && lead.permitted_for?(user)
      end
      can :read, Account do |account|
        account && account.permitted_for?(user)
      end
      can :read, Contact do |contact| 
        contact && contact.permitted_for?(user)
      end
      can :update, Lead do |lead|
        lead && lead.permitted_for?(user)
      end
      can :update, Account do |account|
        account && account.permitted_for?(user)
      end
      can :update, Contact do |contact|
        contact && contact.permitted_for?(user)
      end
    elsif user.role_is?('Freelancer')
      can :create, User
      can :profile, User
      can :read, Lead
      can :create, Lead
      can :read, Account
      can :manage, Task
      can :read, Contact
      can :read, Opportunity
    end
  end
end
