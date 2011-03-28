module DataMapper
  # Tracks the names of changed model attributes, useful for generating actions
  # based on changes in after save/update hooks.
  module Changes
    extend ActiveSupport::Concern

    Model.append_inclusions self

    included do
      after :save do |*args|
        changed.clear if clean?
      end
    end

    def changed
      @changed ||= Set.new
    end

  end
end

module DataMapper
  module Resource
    class State
      class Dirty
        include DataMapper::Hook

        after :set do |state, property, value|
          if resource.attribute_dirty?(property.name) && resource.dirty_attributes[property] != resource.original_attributes[property]
            resource.changed << property.name.to_s
          end
        end
      end
    end
  end
end
