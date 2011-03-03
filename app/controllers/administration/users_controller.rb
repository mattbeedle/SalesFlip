class Administration::UsersController < Administration::AdministrationController

  skip_before_filter :administrator_required, :only => :unmasquerade

  def masquerade
    session[:_user_id] = current_user.id
    sign_in :user, User.get(params[:id])
    redirect_to root_path
  end

  def unmasquerade
    raise CanCan::AccessDenied unless session[:_user_id]

    sign_in :user, User.get(session.delete(:_user_id))
    redirect_to root_path
  end

end
