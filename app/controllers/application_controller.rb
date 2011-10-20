# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ActionController::Caching::Sweeping

  # internal application, doesn't really need forgery protection
  protect_from_forgery

  layout 'application'

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = 'Access denied.'
    redirect_to root_url
  end

  rescue_from DataMapper::ObjectNotFoundError do
    render :file => "public/404.html", :status => 404, :layout => false
  end

  before_filter :store_on_call
  before_filter :authenticate_user!
  before_filter "hook(:app_before_filter, self)"
  after_filter  "hook(:app_after_filter, self)"
  after_filter  :log_viewed_item, :only => :show

  helper :all

protected

  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    render :template => "/errors/#{status[0,3]}.html.haml", :status => status, :layout => 'errors.html.haml'
  end

  def local_request?
    false
  end

  def log_viewed_item
    subject = instance_variable_get("@#{controller_name.singularize}")
    if subject and current_user and subject.respond_to?(:activities) and not subject.is_a?(Search)
      Activity.log(current_user, subject, 'Viewed')
    end
  end

  def return_to_or_default( default )
    if params[:return_to] and not params[:return_to].blank?
      redirect_to params[:return_to]
    else
      redirect_to default
    end
  end

  def store_on_call
    if params[:on_call] == "false"
      cookies.delete(:on_call)
    elsif params[:on_call]
      cookies[:on_call] = params[:on_call]
    end
  end
end
