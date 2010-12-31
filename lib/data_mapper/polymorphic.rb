module DataMapper
  module Model
    module Relationship
      alias :has_without_polymorphism :has

      def has(cardinality, name, *args)
        opts = args.last.kind_of?(::Hash) ? args.pop : {}

        if as = opts.delete(:as)
          name = name.to_s
          suffix = 'type'

          opts[:child_key] = [:"#{as}_id"]
          opts[:"#{as}_type"] = [self, *descendants]

          child_model_name = opts[:model] || opts[:class_name] || name.classify
          child_klass      = child_model_name.constantize
          belongs_to_name  = self.name.demodulize.underscore

          has_without_polymorphism cardinality, name, *(args + [opts])

          # class_eval <<-EVIL, __FILE__, __LINE__+1
            # def #{name}
              # super.all(:#{as}_type => self.class.name)
            # end
          # EVIL

          child_klass.belongs_to "_#{as}_#{belongs_to_name}".to_sym, :child_key => opts[:child_key], :model => self

          child_klass.class_eval <<-EVIL, __FILE__, __LINE__+1
            def #{belongs_to_name}                                                          # def post
              _#{as}_#{belongs_to_name} if #{as}_#{suffix} == '#{self.name}'                #   _commentable_post if commentable_type == 'Post'
            end                                                                             # end

            def #{belongs_to_name}=(object)                                                 # def post=(object)
              self._#{as}_#{belongs_to_name} = object if #{as}_#{suffix} == '#{self.name}'  #   self._commentable_post = object if commentable_type == 'Post'
            end                                                                             # end

            protected :_#{as}_#{belongs_to_name}, :_#{as}_#{belongs_to_name}=
          EVIL
        else
          has_without_polymorphism(cardinality, name, *(args + [opts]))
        end
      end

      alias :belongs_to_without_polymorphism :belongs_to

      def belongs_to(name, *args)
        opts = args.last.kind_of?(::Hash) ? args.pop : {}
        if opts.delete(:polymorphic)
          suffix = 'type'

          property "#{name}_#{suffix}".to_sym, String
          property "#{name}_id".to_sym, Integer, required: opts.has_key?(:required) ? opts[:required] : true

          class_eval <<-EVIL, __FILE__, __LINE__+1
            def #{name}                                                                           # def commentable
              send('_#{name}_' + #{name}_#{suffix}.demodulize.underscore) if #{name}_#{suffix}    #   send('_commentable_' + commentable_type.demodulize.underscore) if commentable_class
            end                                                                                   # end

            def #{name}=(object)                                                                  # def commentable=(object)
              if object                                                                           #   if object
                self.#{name}_#{suffix} = object.class.name                                        #     self.commentable_type = object.class.name
                self.send('_#{name}_' + object.class.name.demodulize.underscore + '=', object)    #     self.send('_commentable_' + object.class.name.demoduleize.underscore + '=', object)
              else                                                                                #   else
                self.subject_id = nil                                                             #     self.subject_id = nil
                self.subject_type = nil                                                           #     self.subject_type = nil
              end                                                                                 #   end
            end                                                                                   # end
          EVIL
        else
          belongs_to_without_polymorphism name, *(args + [opts])
        end
      end
    end
  end
end

