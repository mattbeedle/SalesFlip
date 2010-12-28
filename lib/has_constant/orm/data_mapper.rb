module HasConstant
  module Orm
    module DataMapper
      extend ActiveSupport::Concern

      module ClassMethods
        def has_constant(name, values, options = {})
          singular = (options.delete(:accessor) || name.to_s.singularize).to_sym

          (class << self; self; end).instance_eval do
            define_method(name.to_s, values) if values.respond_to?(:call)
            define_method(name.to_s, lambda { values }) unless values.respond_to?(:call)
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

          class_eval do
            values = values.respond_to?(:call) ? values.call : values

            property singular, ::DataMapper::Property::Enum,
              {flags: values, auto_validation: false}.merge(options)

            validates_within :set => [nil, *values]

            def by_constant(constant, value)
              all(constant.to_sym => value)
            end

            define_method "#{singular}_is" do |*values|
              all(singular.to_sym => values)
            end

            define_method "#{singular}_is_not" do |*values|
              all(singular.to_sym.not => values)
            end
          end
        end
      end
    end
  end
end
