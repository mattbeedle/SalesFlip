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

module ActiveRecordCompatibility
  module Finder

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
  module Model
    alias where all
    include ActiveRecordCompatibility::Finder

    %w(before after).each do |scope|
      %w(save create update destroy).each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{scope}_#{method}(*args, &block)
          #{scope} :#{method}, *args, &block
        end
        RUBY
      end
    end

  end
end

module DataMapper
  class Collection
    include ActiveRecordCompatibility::Finder

    def scoped
      self
    end

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
