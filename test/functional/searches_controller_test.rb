require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in @user = User.make(:matt)
  end

  context 'update' do
    setup do
      @search = Search.make(user: @user)
    end

    context 'when the search is invalid' do
      should 'render the edit page' do
        put :update, id: @search.id, search: { terms: "" }

        assert_template :edit
      end
    end
  end

  context 'show' do
    context 'when search does not exist' do
      should 'return a 404' do
        get :show, :id => 12345

        assert_response :not_found
      end
    end

    context 'when search was created by another user' do
      should 'return a 404' do
        search = Search.make
        get :show, :id => search.id

        assert_response :not_found
      end
    end

    context 'when search belongs to user' do
      should 'be successful' do
        search = Search.make(user: @user)
        get :show, :id => search.id

        assert_response :success
      end
    end

    context 'when solr is not running' do
      setup do
        Sunspot.stubs(:search).raises(Errno::ECONNREFUSED)
      end

      should 'render a temporarily unavailable page' do
        search = Search.make(user: @user)
        get :show, :id => search.id

        assert_response :service_unavailable
      end
    end
  end
end
