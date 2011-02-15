module DataMapper
  module Resque
    extend ActiveSupport::Concern

    Model.append_inclusions self

    def async(method, *args)
      ::Resque.enqueue(self.class, id, method, *args)
    end

    module ClassMethods

      def perform(id, method, *args)
        find(id).send(method, *args)
      end

      def queue
        :background
      end
    end
  end
end
