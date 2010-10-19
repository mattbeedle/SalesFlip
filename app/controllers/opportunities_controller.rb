class OpportunitiesController < InheritedResources::Base
  
  has_scope :stage_is, :type => :array
  has_scope :assigned_to
  
  def create
    create! do |success, failure|
      success.html { redirect_to opportunities_path }
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
    @opportunity ||= current_user.opportunities.build params[:opportunity]
  end
  
  def collection
    @opportunities ||= opportunities.paginate(
      :per_page => params[:per_page] || 10, :page => params[:page] || 1)
  end
  
  def resource
    @opportunity ||= Opportunity.for_company(current_user.company).permitted_for(current_user).
      where(:_id => params[:id]).first
  end
end