require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  context '.permitted_for' do
    context 'when model is assignable' do
      subject { AssignableModel }

      context 'when user is not a freelancer' do
        setup do
          @user = User.make(:role => 'Sales Person')
        end

        should 'return public items' do
          item = subject.create
          assert_includes subject.permitted_for(@user), item
        end

        should 'return private items created by the user' do
          item = subject.create(permission: 'Private', user: @user)
          assert_includes subject.permitted_for(@user), item
        end

        should 'return private items assigned to the user' do
          item = subject.create(permission: 'Private', assignee: @user, user: @user)
          assert_includes subject.permitted_for(@user), item
        end

        should 'return items shared with the user' do
          item = subject.create(permission: 'Shared', permitted_users: [@user])
          assert_includes subject.permitted_for(@user), item
        end

        should 'not return private items created by other users' do
          item = subject.create(permission: 'Private', user: User.make)
          refute_includes subject.permitted_for(@user), item
        end

        should 'not return private items assigned to other users' do
          other_user = User.make
          item = subject.create(permission: 'Private', assignee: other_user, user: other_user)
          refute_includes subject.permitted_for(@user), item
        end

        should 'not return items not shared with the user' do
          other_user = User.make
          item = subject.create(permission: 'Shared', permitted_users: [other_user])
          refute_includes subject.permitted_for(@user), item
        end
      end

      context 'when user is a freelancer' do
        setup do
          @user = User.make(:role => 'Freelancer')
        end

        should 'not return public items' do
          item = subject.create
          refute_includes subject.permitted_for(@user), item
        end

        should 'return private items created by the user' do
          item = subject.create(permission: 'Private', user: @user)
          assert_includes subject.permitted_for(@user), item
        end

        should 'return private items assigned to the user' do
          item = subject.create(permission: 'Private', assignee: @user, user: @user)
          assert_includes subject.permitted_for(@user), item
        end

        should 'return items shared with the user' do
          item = subject.create(permission: 'Shared', permitted_users: [@user])
          assert_includes subject.permitted_for(@user), item
        end

        should 'not return private items created by other users' do
          item = subject.create(permission: 'Private', user: User.make)
          refute_includes subject.permitted_for(@user), item
        end

        should 'not return private items assigned to other users' do
          other_user = User.make
          item = subject.create(permission: 'Private', assignee: other_user, user: other_user)
          refute_includes subject.permitted_for(@user), item
        end

        should 'not return items not shared with the user' do
          other_user = User.make
          item = subject.create(permission: 'Shared', permitted_users: [other_user])
          refute_includes subject.permitted_for(@user), item
        end
      end
    end

    context 'when model is not assignable' do
      subject { NotAssignableModel }

      should 'not attempt to scope by assignee_id' do
        assert_nothing_raised { subject.permitted_for(User.make) }
      end
    end
  end
end
