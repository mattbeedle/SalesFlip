module CanCan

  # Extension class for CanCan's InheritedResource compatibility layer. It
  # replaces the calls to load_collection? and load_collection to use the
  # controller's #collection method instead of #end_of_association_chain.
  #
  # While methods like #resource should be using the association chain
  # (current_user.accounts.new, etc.), the collections should use the declared
  # collections, which employ the more sophisticated permissioning rules.
  class InheritedResource < ControllerResource # :nodoc:

    def load_collection?
      collection.respond_to?(:accessible_by) && !current_ability.has_block?(authorization_action, resource_class)
    end

    def load_collection
      collection.accessible_by(current_ability)
    end

    def collection
      @controller.send :collection
    end

  end
end
