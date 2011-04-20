require 'test_helper'

class LeadsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in @user = User.make(:matt)
  end

  context 'show' do
    context 'when lead does not exist' do
      should 'return a 404' do
        get :show, :id => 12345

        assert_response :not_found
      end
    end

    context 'when id is invalid' do
      should 'return a 404' do
        get :show, :id => "12345,"

        assert_response :not_found
      end
    end
  end
end
