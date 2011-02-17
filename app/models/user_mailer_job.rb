class UserMailerJob
  @queue = :background

  def self.perform(lead_id)
    UserMailer.lead_assignment_notification(Lead.find(lead_id)).deliver
  end
end
