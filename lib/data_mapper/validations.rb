module DataMapper
  class Property
    class Integer

      # HACK: Unfortunately, datamapper doesn't seem to like setting
      # association keys to blank strings, instead requiring something numeric
      # or nil, so we must typecast blank values to nil.
      def typecast(value)
        value.blank? ? nil : super
      end
    end
  end
end

module DataMapper
  module Validations
    module AutoValidations

      # HACK: this method is copied directly from dm-validations, save for a
      # single line addition to pass along allow_blank from the property to the
      # validator.
      def auto_generate_validations(property)
        return if disabled_auto_validations? || skip_auto_validation_for?(property)

        # all auto-validations (aside from presence) should skip
        # validation when the value is nil
        opts = { :allow_nil => true }

        opts[:allow_blank] = property.allow_blank? # <- this is the hack!

        if property.options.key?(:validates)
          opts[:context] = property.options[:validates]
        end

        infer_presence_validation_for(property, opts.dup)
        infer_length_validation_for(property, opts.dup)
        infer_format_validation_for(property, opts.dup)
        infer_uniqueness_validation_for(property, opts.dup)
        infer_within_validation_for(property, opts.dup)
        infer_type_validation_for(property, opts.dup)
      end # auto_generate_validations

    end
  end
end
