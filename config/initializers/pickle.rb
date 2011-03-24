module Pickle
  module Session
    def create_model(pickle_ref, fields = nil)
      factory, label = *parse_model(pickle_ref)

      raise ArgumentError, "Can't create with an ordinal (e.g. 1st user)" if label.is_a?(Integer)

      fields = fields.is_a?(Hash) ? parse_hash(fields) : parse_fields(fields)
      factory = pickle_config.factories["#{label}_#{factory}"] || pickle_config.factories[factory]

      record = factory.create(fields)
      store_model(factory, label, record)
      record
    end
  end
end
