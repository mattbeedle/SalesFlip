class SearchesController < InheritedResources::Base

  def index
    redirect_to :action => :new
  end

protected
  def begin_of_association_chain
    current_user
  end
end
