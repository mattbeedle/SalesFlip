class CampaignsController < InheritedResources::Base

  def create
    create! do |success, failure|
      success.html { redirect_to campaigns_path }
    end
  end

  protected

  def create_resource(campaign)
    campaign.user = current_user
    super
  end

  def update_resource(campaign, attributes)
    attributes[:updater] = current_user
    super
  end

end
