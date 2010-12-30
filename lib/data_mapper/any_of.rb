module DataMapper
  module AnyOf
    extend ActiveSupport::Concern

    Model.append_inclusions self

    module ClassMethods
      def any_of(*args)
        args.inject(nil) do |collection, query|
          collection ? collection | all(query) : all(query)
        end
      end
    end

  end
end
