class Administration::AdministrationController < ApplicationController

  layout 'administration'

  before_filter :administrator_required

protected
  def administrator_required
    raise CanCan::AccessDenied unless current_user.role_is?('Administrator')
  end
end
