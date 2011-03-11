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
      OfferRequestJob.perform(@opportunity.id)
    end

    should "sets the stage to offer requested" do
      assert_equal @stage, @opportunity.reload.stage
    end
  end
end
