class EmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  def create
    Comment.create! :user => User.first, :commentable => Lead.first, :text => params[:email][:raw]
    if request.headers['Authorization'] != '20015510-959d-012d-a4ae-001c25a0b06f'
      return head(:unauthorized)
    else
      UserMailer.receive(params[:email][:raw])
      head :ok
    end
  end
end
