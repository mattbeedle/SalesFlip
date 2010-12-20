class Administration::OpportunitiesController < Administration::AdministrationController
  inherit_resources

  def index
    @stages = current_user.company.opportunity_stages.not_deleted.where(:percentage.gt => 0)
    @start_date = !params[:start_date].blank? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    @end_date = !params[:end_date].blank? ? Date.parse(params[:end_date]) : Date.today
    @days = (@end_date - @start_date).to_i
    index! do |format|
      format.html
    end
  end

protected
  def collection
    @opportunities ||= Opportunity.for_company(current_user.company)
  end
end
