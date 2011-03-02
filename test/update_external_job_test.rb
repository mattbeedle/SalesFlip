require "test_helper"

class UpdateExternalJobTest < ActiveSupport::TestCase

  setup do
    @json = User.new.to_json
    @url = Rails.configuration.external_user_update_url
    Encryptor.expects(:encrypt).with(value: json).returns("testing")
  end

  describe ".perform" do

    it "posts the encrypted user data" do
      HTTParty.expects(:post).with(@url, query: { user: "testing" })
      described_class.perform(@json)
    end
  end
end
