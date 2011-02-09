class CampaignsController < InheritedResources::Base

  def create
    create! do |success, failure|
      success.html { redirect_to campaigns_path }
    end
  end

  protected

  def end_of_association_chain
    super.not_deleted
  end

  def create_resource(campaign)
    campaign.user = current_user
    super
  end

  def update_resource(campaign, attributes)
    attributes[:updater] = current_user
    super
  end

end
