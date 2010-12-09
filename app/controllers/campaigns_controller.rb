class CampaignsController < InheritedResources::Base

  def create
    create! do |success, failure|
      success.html { redirect_to campaigns_path }
    end
  end

end
