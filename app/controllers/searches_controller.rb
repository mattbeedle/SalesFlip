class SearchesController < InheritedResources::Base

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
