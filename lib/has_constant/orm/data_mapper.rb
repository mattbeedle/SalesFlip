module HasConstant
  module Orm
    module DataMapper

      # Simple module for automatically executing a proc when a missing method
      # is called.
      #
      # @example
      #   statuses = -> { I18n.t(:statuses) }.extend(CallAutomatically)
      #   I18n.with_locale(:en) { statuses.to_a }
      #     # => ["New", "Converted"]
      #   I18n.with_locale(:de) { statuses.to_a }
      #     # => ["Neu", "Konvertiert"]
      #
      module CallAutomatically
        def method_missing(*args, &block)
          call.__send__(*args, &block)
        end
      end

      class TranslatedEnum < ::DataMapper::Property::Enum

        attr_reader :flags

        # The TranslatedEnum works identically to dm-type's Enum class, except
        # it allows for it's flags to be specified by either an Array or a Proc
        # which returns an array.
        #
        # @example
        #   Lead.property :status, TranslatedEnum, flags: ->{ I18n.t(:statuses) }
        #
        def initialize(model, name, options = {})
          # Store the flags as provided by the caller
          @flags = options.fetch(:flags).extend(CallAutomatically)

          # DM's Enum processes the flags on initialize, so we reset the flags
          # here. It uses #flag_map at run-time to load/dump the property,
          # which we've overridden to use the original flags.
          options[:flags] = []

          super
        end

        # Calls Property#set, but includes the current locale as a part of the
        # value.
        def set(resource, value)
          value, locale = value
          super resource, [value, locale || I18n.locale]
        end

        # Loads the value using the current locale
        def load(value)
          return flag_map[I18n.locale][value], I18n.locale
        end

        # Dumps the value using the current locale, or the locale contained in
        # the value.
        def dump(value)
          value, locale = value
          flag_map[locale || I18n.locale].invert[value]
        end

        private

        # @example
        #   property.flag_map
        #   # => {en: {1 => "Mr", 2 => "Mrs"}, de: {1 => "Herr", 2 => "Frau"}}
        # @return Hash a hash of locale to translation key mappings
        def flag_map
          @flag_map = Hash.new do |hash, locale|
            map = I18n.with_locale(locale) { flags.map.with_index { |_,i| [_, i+1] } }
            hash[locale] = Hash[*map.flatten.reverse]
          end
        end

        # Defines a custom reader method on the model which runs through the
        # dump / load process to allow values to always be translated.
        def bind
          model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}
            property = properties[#{name.inspect}]
            property.load(property.dump(property.get(self))).first
          end
          RUBY
        end

      end

      extend ActiveSupport::Concern

      module ClassMethods
        def has_constant(name, values, options = {})
          singular = (options.delete(:accessor) || name.to_s.singularize).to_sym

          class_eval do
            if values.respond_to?(:call)
              values.extend(CallAutomatically)

              property singular, TranslatedEnum,
                {flags: values, auto_validation: false}.merge(options)
            else
              property singular, ::DataMapper::Property::Enum,
                {flags: values, auto_validation: false}.merge(options)
            end

            validates_within :set => values, :allow_blank => true
          end

          define_method("#{singular}_is?") do |value|
            send(singular) == value.to_s
          end

          define_method("#{singular}_is_not?") do |value|
            !send("#{singular}_is?", value)
          end

          define_method("#{singular}_in?") do |value_list|
            value_list.include? send(singular)
          end

          define_method("#{singular}_not_in?") do |value_list|
            !send("#{singular}_in?", value_list)
          end

          (class << self; self; end).instance_eval do
            define_method(name.to_s, values) if values.respond_to?(:call)
            define_method(name.to_s, lambda { values }) unless values.respond_to?(:call)

            def by_constant(constant, value)
              all(constant.to_sym => value)
            end

            define_method "#{singular}_is" do |*values|
              all(singular.to_sym => values.flatten)
            end

            define_method "#{singular}_is_not" do |*values|
              all(singular.to_sym.not => values.flatten)
            end
          end
        end
      end
    end
  end
end
