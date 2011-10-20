class UsersController < InheritedResources::Base
  before_filter :load_current_user, :only => [ :profile ]
  skip_before_filter :authenticate_user!, :only => [ :new, :create ]
  skip_before_filter :log_viewed_item
  before_filter :invitation, :only => [ :new, :create ]

  load_and_authorize_resource

  def new
    redirect_to root_url and return
  end

  def create
    create! do |success, failure|
      success.html { redirect_to root_path }
    end
  end

protected
  def invitation
    if params[:invitation_code]
      @invitation ||= Invitation.first(:conditions => { :code => params[:invitation_code] })
    end
  end

  def build_resource
    attributes = params[:user] || {}
    if invitation
      attributes.merge!(:invitation_code => invitation.code, :role => invitation.role)
      @user ||= User.new attributes
    else
      @user ||= User.new attributes
    end
  end

  def collection
    @users ||= current_user.company.users.asc(:username)
  end

  def load_current_user
    @user ||= current_user
  end
end
