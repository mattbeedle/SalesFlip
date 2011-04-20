require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in user
  end

  context 'show' do
    context 'when lead does not exist' do
      should 'return a 404' do
        get :show, :id => 12345

        assert_response :not_found
      end
    end
  end

  context 'edit' do
    context 'when the task belongs to another user' do

      should 'return not authorized' do
        task = Task.make(user: admin)
        get :edit, :id => task.id

        assert_not_nil flash[:error]
      end

      context 'and signed in as an admin' do
        should 'be successful' do
          sign_in admin
          task = Task.make(user: user)
          get :edit, :id => task.id
          assert_response :success
        end
      end

    end
  end

  def admin
    @admin ||= User.make(:matt)
  end

  def user
    @user ||= User.make
  end
end
