module DataMapper
  module AttributeCleaner
    extend ActiveSupport::Concern

    Model.append_inclusions self

    module ClassMethods

      # Performs basic data cleanup on the attribute list provided.
      #
      # @example
      #   Person.property :name, String
      #   Person.property :email, String
      #   Person.clean_attributes :name, :email
      #
      #   Person.new(name: "\tJohn'", email: '"\r\nemail').attributes
      #   # => { name: "John", email: "email" }
      #
      # @param [Array<Symbol>] attributes the attributes to clean
      def clean_attributes(*attributes)
        attributes.each do |attribute|
          define_method :"#{attribute}=" do |value|
            attribute_set(
              attribute,
              clean_attribute(value)
            )
          end
        end
      end

    end

    private

    def clean_attribute(value)
      return value unless value.is_a?(String)

      value.gsub(/^['"\s]+|['"\s]+$/, '')
    end

  end
end
