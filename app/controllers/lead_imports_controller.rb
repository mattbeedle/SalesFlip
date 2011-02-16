class LeadImportsController < ApplicationController
  inherit_resources

  skip_before_filter :log_viewed_item

  def show
    resource
    @imported = resource.imported.paginate(
      :per_page => params[:per_page] || 20, :page => params[:page] || 1)
  end

  def create
    create! do |success, failure|
      success.html { redirect_to edit_lead_import_path(@lead_import) }
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Your leads are being imported now. You will receive a summary email when the import has finished. You can also keep refreshing this page to see the import progress."
        @lead_import.async(:import)
        redirect_to lead_import_path(@lead_import)
      end
    end
  end

protected
  def build_resource
    @lead_import ||= current_user.lead_imports.build params[:lead_import]
  end
end
