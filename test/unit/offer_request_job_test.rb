require 'test_helper'

class OfferRequestJobTest < ActiveSupport::TestCase

  setup do
    @stage = OpportunityStage.make(name: "Offer Requested")
    @opportunity = Opportunity.make
  end

  context ".perform" do

    setup do
      HTTParty.expects(:post).with(
        Rails.configuration.external_user_update_url,
        query: { data: Encryptor.encrypt(value: @opportunity.to_json) }
      )
    end

    should "send the information to jobboards" do
      OfferRequestJob.perform(@opportunity.id)
    end
  end
end
