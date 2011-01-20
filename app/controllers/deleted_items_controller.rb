class DeletedItemsController < ApplicationController

  before_filter :admin_required
  before_filter :resource, :only => [ :update, :destroy ]

  def index
    @items ||= [
      Campaign.where(:deleted_at.not => nil).entries +
      Lead.permitted_for(current_user).where(:deleted_at.not => nil).entries +
      Contact.permitted_for(current_user).where(:deleted_at.not => nil).entries +
      Account.permitted_for(current_user).where(:deleted_at.not => nil).entries +
      Comment.permitted_for(current_user).where(:deleted_at.not => nil).entries
    ].flatten.sort_by(&:deleted_at)
  end

  def update
    @item.update :deleted_at => nil
    redirect_to deleted_items_path
  end

  def destroy
    @item.destroy_without_paranoid
    return_to_or_default deleted_items_path
  end

protected
  def resource
    @item = params[:type].constantize.get(params[:id])
  end

  def admin_required
    raise CanCan::AccessDenied unless current_user.role_is?('Administrator')
  end
end
