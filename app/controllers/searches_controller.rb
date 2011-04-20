class SearchesController < InheritedResources::Base

  rescue_from Errno::ECONNREFUSED do
    render "solr_not_running",
      status: :service_unavailable,
      layout: nil
  end

  def index
    redirect_to :action => :new
  end

  def show
    @results ||= resource.results(params[:per_page] || 30, params[:page] || 1)
  end

protected
  def begin_of_association_chain
    current_user
  end
end
