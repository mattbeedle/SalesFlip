require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in @user = User.make(:matt)
  end

  context 'show' do
    context 'when contact does not exist' do
      should 'return a 404' do
        get :show, :id => 12345

        assert_response :not_found
      end
    end
  end
end
