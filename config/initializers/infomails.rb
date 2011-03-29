if Rails.env.staging? || Rails.env.production?
  Salesflip::Application.configure do
    config.action_mailer.smtp_settings = {
      :address => "smtp.sendgrid.net",
      :user_name => ENV['SENDGRID_USER_NAME'],
      :password => ENV['SENDGRID_PASSWORD']
    }

    # We want to deliver infomail emails through a trusted source (in this case,
    # SendGrid).
    config.after_initialize do
      InfomailMailer.default delivery_method: :smtp
    end
  end
end
