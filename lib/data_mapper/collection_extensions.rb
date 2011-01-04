module DataMapper
  module Model
    alias where all
  end
end

module DataMapper
  class Collection
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
