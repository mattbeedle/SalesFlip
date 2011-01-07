module DataMapper
  module Associations
    module ManyToOne #:nodoc:
      class Relationship < Associations::Relationship
        def get!(resource)
          if parent = resource.instance_variable_get(instance_variable_name)
            parent = resource_for(resource) if parent_key.get!(parent) != source_key.get!(resource)
          end

          parent
        end
      end
    end
  end
end
