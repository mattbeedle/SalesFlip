class OpportunitiesController < InheritedResources::Base

  has_scope :stage_is, :type => :array
  has_scope :assigned_to

  def new
    build_resource
    3.times { @opportunity.attachments.build }
  end

  def create
    create! do |success, failure|
      success.html { return_to_or_default opportunities_path }
      failure.html do
        3.times do
          @opportunity.attachments.build
        end unless @opportunity.attachments.any?
        render :action => :new
      end
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
    @opportunities = apply_scopes(Opportunity).not_deleted
  end

  def build_resource
    attributes = { :contact_id => params[:contact_id] }.merge(params[:opportunity] || {})
    @opportunity ||= current_user.opportunities.build attributes
  end

  def collection
    @opportunities ||= opportunities.
      desc(:created_at).paginate(:per_page => params[:per_page] || 10,
                                 :page => params[:page] || 1)
  end

  def resource
    @opportunity ||= Opportunity.for_company(current_user.company).
      where(:id => params[:id]).first
  end
end
