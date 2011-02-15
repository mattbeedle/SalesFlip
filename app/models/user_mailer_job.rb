class UserMailerJob
  @queue = :background

  def self.perform(user_id)
    UserMailer.lead_assignment_notification(User.find(user_id)).deliver
  end
end
