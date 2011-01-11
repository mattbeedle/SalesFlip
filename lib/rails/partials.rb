module ActionView
  module Partials
    class PartialRenderer
      private

      def collection
        if @options.key?(:collection)
          collection = @options[:collection]
        end
      end
    end
  end
end
