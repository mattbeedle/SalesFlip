class ImportMailer < ActionMailer::Base
  default :from => 'service@salesflip.com'

  def import_summary(import)
    @import = import

    mail(:to => import.user.email, :subject => I18n.t('emails.import_summary.subject'),
         :reply_to => 'service@salesflip.com')
  end
end
