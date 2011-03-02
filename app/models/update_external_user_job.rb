# encoding: utf-8
#
# This job handles the communication with salesflip for user data.
class UpdateExternalUserJob
  @queue = :external

  # Given the supplied user JSON this will encrypt the data and send it to
  # salesflip to be processed.
  #
  # @example Execute the job.
  #   UpdateExternalUserJob.perform(user.to_json)
  #
  # @param [ String ] user_json the user as JSON.
  def self.perform(user_json)
    HTTParty.post(
      Rails.configuration.external_user_update_url,
      query: { user: Encryptor.encrypt(value: user_json) }
    )
  end
end
