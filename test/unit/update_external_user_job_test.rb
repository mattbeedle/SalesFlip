require "test_helper"

class UpdateExternalUserJobTest < ActiveSupport::TestCase

  setup do
    @json = User.new.to_json
    @url = Rails.configuration.external_user_update_url
    Encryptor.expects(:encrypt).with(value: @json).returns("testing")
  end

  context ".perform" do

    should "post the encrypted user data" do
      HTTParty.expects(:post).with(@url, query: { data: "testing" })
      UpdateExternalUserJob.perform(@json)
    end
  end
end
