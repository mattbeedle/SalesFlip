# encoding: utf-8
#
# This job handles the communication with jobboards for offer requests.
class OfferRequestJob
  @queue = :offer_requests

  # Given the supplied opportunity id send the information to jobboards and
  # then update the opportunity stage.
  #
  # @example Execute the job.
  #   OfferRequestJob.perform(123)
  #
  # @param [ Integer ] The id of the opportunity.
  def self.perform(opportunity_id)
    Opportunity.find(opportunity_id).tap do |opportunity|
      HTTParty.post(
        Rails.configuration.external_user_update_url,
        query: { data: Encryptor.encrypt(value: opportunity.to_json) }
      )
    end
  end
end
