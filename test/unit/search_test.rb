require 'test_helper.rb'

class SearchTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :terms, :user_id, :created_at, :updated_at, :collections
    should_belong_to :user
    should_validate_presence_of :terms
  end
end
