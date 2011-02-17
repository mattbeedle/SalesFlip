class InfomailMailer < ActionMailer::Base
  default :from => 'service@salesflip.com'

  def mailer(lead, template)
    template = template

    template.attachments.each do |attachment|
      attachment = attachment.attachment

      filename = File.basename(attachment.url)

      attachments[filename] = attachment.read
    end

    mail(:to => lead.email,
         :subject => template.subject,
         :body => template.body)
  end

end
