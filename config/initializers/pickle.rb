module Pickle
  module Session
    alias default_create_model create_model

    def create_model(pickle_ref, fields = nil)
      factory, label = *parse_model(pickle_ref)
      factory = "#{label}_#{factory}" unless label.blank?
      raise ArgumentError, "Can't create with an ordinal (e.g. 1st user)" if label.is_a?(Integer)
      fields = fields.is_a?(Hash) ? parse_hash(fields) : parse_fields(fields)
      factory = pickle_config.factories[factory]
      if factory
        record = factory.create(fields)
        store_model(factory, label, record)
        record
      else
        default_create_model(pickle_ref, fields)
      end
    end
  end
end
