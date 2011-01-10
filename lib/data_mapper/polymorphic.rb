module DataMapper
  module Model
    module Relationship
      alias :has_without_polymorphism :has

      def __polymorphic_relationships__
        @polymorphic_relationships ||= Hash.new { |h, k| h[k] = ::Set.new }
      end

      def has(cardinality, name, *args)
        opts = args.last.kind_of?(::Hash) ? args.pop : {}

        if as = opts.delete(:as)
          target_class = name.to_s.classify.constantize

          relationships = target_class.__polymorphic_relationships__[as]
          relationships << target_class.belongs_to(self.name.underscore, required: false)

          has_without_polymorphism cardinality, name, target_class, inverse: self.name.underscore.to_sym
        else
          has_without_polymorphism cardinality, name, *(args + [opts])
        end
      end

      alias :belongs_to_without_polymorphism :belongs_to

      def belongs_to(name, *args)
        opts = args.last.kind_of?(::Hash) ? args.pop : {}

        if opts.delete(:polymorphic)
          class_eval <<-RUBY, __FILE__, __LINE__+1

          def #{name}_id
            #{name}.try(:id)
          end

          def #{name}_type
            #{name}.try(:class)
          end

          def #{name}_id=(id)
            if @#{name}_type.present?
              __set_polymorphic_form_type_and_id__(@#{name}_type, id)
            else
              @#{name}_id = id
            end
          end

          def #{name}_type=(type)
            if @#{name}_id.present?
              __set_polymorphic_form_type_and_id__(type, @#{name}_id)
            else
              @#{name}_type = type
            end
          end

          def #{name}
            if defined?(@#{name})
              @#{name}
            else
              self.class.__polymorphic_relationships__[:#{name}].each do |relationship|
                object = relationship.get(self)
                return @#{name} = object if object
              end
              @#{name} = nil
            end
          end

          def #{name}=(object)
            @#{name} = object

            if object
              self.class.__polymorphic_relationships__[:#{name}].each do |relationship|
                if relationship.target_model.base_model == object.class.base_model
                  relationship.set(self, object)
                else
                  relationship.set(self, nil)
                end
              end
            else
              self.class.__polymorphic_relationships__[:#{name}].each do |relationship|
                relationship.set(self, nil)
              end
            end
          end

          private
          def __set_polymorphic_form_type_and_id__(type, id)
            self.class.__polymorphic_relationships__[:#{name}].each do |relationship|
              if relationship.target_model.base_model.name == type
                relationship.child_key.set(self, [id])
              else
                relationship.child_key.set(self, [nil])
              end
            end
          end

          RUBY
        else
          belongs_to_without_polymorphism name, *(args + [opts])
        end
      end
    end
  end
end

