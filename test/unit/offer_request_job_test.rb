require 'test_helper'

class OfferRequestJobTest < ActiveSupport::TestCase

  setup do
    @stage = OpportunityStage.make(name: "Offer Requested")
    @opportunity = Opportunity.make(contact: Contact.make)
  end

  context ".perform" do

    setup do
      Encryptor.expects(:encrypt).returns("testing")
      HTTParty.expects(:post).with(
        Rails.configuration.external_offer_request_url,
        query: { data: "testing" }
      )
    end

    should "send the information to jobboards" do
      OfferRequestJob.perform(@opportunity.id)
    end
  end
end
