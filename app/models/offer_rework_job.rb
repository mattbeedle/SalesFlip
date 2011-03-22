# encoding: utf-8
#
# This job handles the communication with jobboards for offer reworks.
class OfferReworkJob
  @queue = :offer_requests

  # Given the supplied opportunity id send the information to jobboards and
  # then update the opportunity stage.
  #
  # @example Execute the job.
  #   OfferReworkJob.perform(123)
  #
  # @param [ Integer ] The id of the opportunity.
  def self.perform(opportunity_id)
    Opportunity.find(opportunity_id).tap do |opportunity|
      HTTParty.post(
        Rails.configuration.external_offer_rework_url,
        query: { data: Encryptor.encrypt(
          value: opportunity.to_json(methods: [ :serializable_comments ])
        )}
      )
    end
  end
end
