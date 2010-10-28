class EmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  def create
    if request.headers['Authorization'] != '20015510-959d-012d-a4ae-001c25a0b06f'
      return head(:unauthorized)
    else
      @queued_mail = MailQueue.create :mail => params[:email][:raw]
      if UserMailer.receive(Mail.new(@queued_mail.mail))
        @queued_mail.update_attributes :status => 'Success'
      else
        @queued_mail.update_attributes :status => 'Failed'
      end
    end
  rescue
    MailQueue.create :mail => params[:email][:raw], :status => 'Failed' unless @queued_mail
  ensure
    head :ok
  end
end
