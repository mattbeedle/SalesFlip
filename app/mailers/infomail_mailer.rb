class InfomailMailer < ActionMailer::Base
  default :from => 'service@salesflip.com'

  def mailer(lead, template)
    @salutation = case I18n.with_locale(:en) { lead.salutation }
                  when "Mr"
                    I18n.translate(:dear_sir)
                  when "Ms"
                    I18n.translate(:dear_miss)
                  when "Mrs"
                    I18n.translate(:dear_madam)
                  end

    @infomail_template = template
    @user = lead.assignee

    template.attachments.each do |attachment|
      attachment = attachment.attachment

      filename = File.basename(attachment.url)

      attachments[filename] = attachment.read
    end

    mail(:to => lead.email,
         :reply_to => @user.email,
         :subject => template.subject)
  end

end
