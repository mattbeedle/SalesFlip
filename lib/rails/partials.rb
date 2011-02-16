module ActionView
  module Partials
    class PartialRenderer
      private

      # Returns the collection provided to the render call if present.
      #
      # @note Rails normally calls `to_a` on the collection inside this method,
      #       but this is unwanted behavior with DataMapper, since only
      #       Collections (and not Arrays) can be strategically eager loaded.
      def collection
        @options[:collection] if @options.key?(:collection)
      end
    end
  end
end
