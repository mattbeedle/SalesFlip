class InvitationMailerJob
  @queue = :background

  def self.perform(invitation_id)
    InvitationMailer.invitation(Invitation.find(invitation_id)).deliver
  end
end
