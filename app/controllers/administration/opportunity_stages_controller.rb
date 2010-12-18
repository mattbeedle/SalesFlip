class Administration::OpportunityStagesController < Administration::AdministrationController
  inherit_resources

  before_filter :resource, :only => [ :confirm_delete ]

  def create
    create! do |success, failure|
      success.html { redirect_to administration_root_path }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to administration_root_path }
    end
  end

protected
  def build_resource
    @opportunity_stage ||= current_user.company.opportunity_stages.build params[:opportunity_stage]
  end
end
