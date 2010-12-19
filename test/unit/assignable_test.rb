require 'test_helper'

class AssignableClass
  include Mongoid::Document
  include Mongoid::Timestamps
end

class AssignableTest < ActiveSupport::TestCase
  context 'Class' do
    setup do
      AssignableClass.send(:include, Assignable)
    end

    should 'have field "assignee_id"' do
      assert AssignableClass.fields.map(&:first).include?('assignee_id')
    end

    should 'have belong to "assignee"' do
      assert AssignableClass.associations.any? do |name, association|
        association.to_s.match(/ReferencedIn/) && name == arg.to_s
      end
    end

    context 'assigned_to' do
      setup do
        @user = User.make
        @assignable1 = AssignableClass.create! :assignee => @user
        @assignable2 = AssignableClass.create!
      end

      should 'be able to find all assignable models assigned to a user' do
        assert_equal [@assignable1], AssignableClass.assigned_to(@user.id).to_a
      end

      should 'work with strings' do
        assert_equal [@assignable1], AssignableClass.assigned_to(@user.id.to_s).to_a
      end

      should 'work with objects' do
        assert_equal [@assignable1], AssignableClass.assigned_to(@user).to_a
      end
    end
  end

  context 'Instance' do
    setup do
      AssignableClass.send(:include, Assignable)
      @assignable = AssignableClass.new
    end

    should 'know if it is assigned to a user' do
      user = User.make
      @assignable.assignee = user
      assert @assignable.assigned_to?(user)
    end

    should 'know if it is not assigned to a user' do
      user = User.make
      assert !@assignable.assigned_to?(user)
    end
  end
end
