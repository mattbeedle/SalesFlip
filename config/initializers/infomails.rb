if Rails.env.staging? || Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :user_name => ENV['SENDGRID_USER_NAME'],
    :password => ENV['SENDGRID_PASSWORD']
  }

  # We want to deliver infomail emails through a trusted source (in this case,
  # SendGrid).
  InfomailMailer.default delivery_method: :smtp
end
