require 'sunspot/rails'

module Sunspot
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'sunspot_rails.init' do
        Sunspot.session = Sunspot::Rails.build_session
        ActiveSupport.on_load('dm-core') do
          include(Sunspot::Rails::RequestLifecycle)
        end
      end

      rake_tasks do
        load 'sunspot/rails/tasks.rb'
      end

      generators do
        load "generators/sunspot_rails.rb"
      end

    end
  end
end

module Sunspot
  module DataMapper
    def self.included(base)
      base.class_eval do
        extend Sunspot::Rails::Searchable::ActsAsMethods
        Sunspot::Adapters::DataAccessor.register(DataAccessor, base)
        Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, base)
      end
    end

    class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
      def id
        @instance.id
      end
    end

    class DataAccessor < Sunspot::Adapters::DataAccessor
      def load(id)
        @clazz.get(id)
      end

      def load_all(ids)
        @class.all(id: ids)
      end
    end
  end
end
