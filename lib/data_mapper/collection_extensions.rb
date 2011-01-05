module DataMapper
  module Resource
    def update_attributes(*args)
      update(*args)
    end

    def new_record?
      new?
    end
  end
end

module DataMapper
  module Model
    alias where all

    def find(scope = :first, options = {})
      collection = all(options)
      case scope
      when Integer, String
        collection.get(scope)
      when :first
        collection.first
      when :all
        collection
      else
        raise ArgumentError, "Unsupported call to find, with scope #{scope}.inspect and options #{options.inspect}"
      end
    end

  end
end

module DataMapper
  class Collection
    def build(*args)
      new(*args)
    end

    def asc(*keys)
      all(order: keys.map(&:asc))
    end

    def desc(*keys)
      all(order: keys.map(&:desc))
    end

    def limit(limit)
      all(limit: limit)
    end

    alias where all
  end
end
