class InvitationMailer < ActionMailer::Base
  default :from => 'service@salesflip.com'

  def invitation( invitation )
    @invitation = invitation
    mail(:to => invitation.email, :subject => I18n.t('emails.invitation.subject'),
         :reply_to => 'do-not-reply@salesflip.com')
  end
end
