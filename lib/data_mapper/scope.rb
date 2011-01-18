module DataMapper

  # There is currently a bug in the scoping code for dm-core which hasn't
  # yet been addressed. This is my hack to get everything working as we
  # need it to.
  #
  # [ http://datamapper.lighthouseapp.com/projects/20609/tickets/1354 ]
  class Collection
    def delegate_to_model(method, *args, &block)
      model = self.model
      self & model.send(method, *args, &block)
    end
  end

end
