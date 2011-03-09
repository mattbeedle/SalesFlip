require 'test_helper.rb'

class AbilityTest < ActiveSupport::TestCase

  def ability
    @ability ||= Ability.new(@user)
  end

  ['Sales Person', 'Key Account Manager', 'Freelancer'].each do |role|
    context role do
      setup do
        @user = User.new(:role => role)
      end

      [Lead, Opportunity, Account, Contact].each do |model|
        name = model.name.downcase
        if role == 'Freelancer'
          should "not be able to view any #{name}'s contact details" do
            instance = model.new
            assert ability.cannot?(:view_contact_details, instance)
          end

          should "be able to view assigned #{name}'s contact details" do
            instance = model.new(:assignee => @user)
            assert ability.can?(:view_contact_details, instance)
          end
        else
          should "be able to view any #{name}'s contact details" do
            instance = model.new
            assert ability.can?(:view_contact_details, instance)
          end
        end
      end

      [Task, Lead, Opportunity, Account, Contact].each do |model|
        name = model.name.tableize

        should "be able to update assigned #{name}" do
          instance = model.new(:assignee => @user)
          assert ability.can?(:update, instance)
        end

        should "not be able to update unassigned #{name}" do
          assert ability.cannot?(:update, model.new)
        end

        should "be able to destroy assigned #{name}" do
          instance = model.new(:assignee => @user)
          assert ability.can?(:destroy, instance)
        end

        should "not be able to destroy unassigned #{name}" do
          assert ability.cannot?(:destroy, model.new)
        end

        should "be able to view all #{name}" do
          instance = model.new
          assert ability.can?(:read, instance)
        end

        should "be able to create new #{name}" do
          assert ability.can?(:create, model)
        end

      end

      should "be able to update their account" do
        assert ability.can?(:update, @user)
      end

      should "not be able to update other's accounts" do
        assert ability.cannot?(:update, User.new)
      end

      should "be able to view other's accounts" do
        assert ability.can?(:read, User.new)
      end
    end
  end

  context 'Service Person' do
    setup do
      @user = User.new(:role => 'Service Person')
    end

    should 'be able to manage assigned leads' do
      assert ability.can?(:create, Task)
      assert ability.can?(:read, Task.new)
      assert ability.can?(:update, Task.new(:assignee => @user))
      assert ability.can?(:destroy, Task.new(:assignee => @user))
    end

    should 'be able to manage leads' do
      lead = Lead.new
      assert ability.can?(:manage, Lead)
    end

    should 'be able to manage accounts' do
      account = Account.new
      assert ability.can?(:create, Account)
      assert ability.can?(:read, account)
      assert ability.can?(:update, account)
      assert ability.can?(:destroy, account)
    end

    should 'be able to manage contacts' do
      contact = Contact.new
      assert ability.can?(:create, Contact)
      assert ability.can?(:read, contact)
      assert ability.can?(:update, contact)
      assert ability.can?(:destroy, contact)
    end

    should 'be able to manage opportunities' do
      opportunity = Opportunity.new
      assert ability.can?(:create, Opportunity)
      assert ability.can?(:read, opportunity)
      assert ability.can?(:update, opportunity)
      assert ability.can?(:destroy, opportunity)
    end

    should "be able to update their account" do
      assert ability.can?(:update, @user)
    end

    should "not be able to update other's accounts" do
      assert ability.cannot?(:update, User.new)
    end

    should "be able to view other's accounts" do
      assert ability.can?(:read, User.new)
    end
  end

  context 'Administrator' do
    setup do
      @user = User.new(:role => 'Administrator')
    end

    should "be able to manage everything" do
      assert ability.can?(:manage, :all)
    end
  end
end
