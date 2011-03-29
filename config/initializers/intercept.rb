if Rails.env.staging?
  Salesflip::Application.configure do
    # Intercept all emails and send them to the user who initiated the action.
    config.after_initialize do
      class Interceptor
        cattr_accessor :to

        def self.delivering_email(mail)
          if to
            mail.to = to
            mail.cc = nil
            mail.bcc = nil
          end
        end
      end

      ApplicationController.before_filter do
        Interceptor.to = current_user.try(:email)
      end

      ActionMailer::Base.register_interceptor(Interceptor)
    end
  end
end
