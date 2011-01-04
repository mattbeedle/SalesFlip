class OpportunitiesController < InheritedResources::Base

  has_scope :stage_is, :type => :array
  has_scope :assigned_to

  def index
    @opportunity_stages = current_user.company.opportunity_stages.not_deleted
    @all_opportunities = Opportunity.not_deleted.permitted_for(current_user)
    index! do |format|
      format.html
    end
  end

  def new
    build_resource
    @opportunity.attachments.build
  end

  def create
    create! do |success, failure|
      success.html { return_to_or_default opportunities_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to opportunities_path }
    end
  end

protected
  def begin_of_association_chain
    current_user
  end

  def opportunities
    @opportunities = apply_scopes(Opportunity).not_deleted.permitted_for(current_user)
  end

  def build_resource
    attributes = { :contact_id => params[:contact_id] }.merge(params[:opportunity] || {})
    @opportunity ||= current_user.opportunities.build attributes
  end

  def collection
    @opportunities ||= opportunities.paginate(
      :per_page => params[:per_page] || 10, :page => params[:page] || 1)
  end

  def resource
    @opportunity ||= Opportunity.for_company(current_user.company).permitted_for(current_user).
      where(:id => params[:id]).first
  end
end
