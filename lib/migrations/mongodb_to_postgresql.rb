module Migrations
  class MongodbToPostgresql < ActiveRecord::Migration
    SKIP = [ "_sphinx_id", "_type", "budget", "contact_person", "region", "freelancer_id" ]

    class << self
      def columns(attributes = {})
        attributes.keys.sort.collect do |key|
          key =~ /_id/ ? "\"legacy_#{key}\"".gsub("__", "_") : "\"#{key}\""
        end.join(",")
      end

      def command(table_name, attributes = {})
        "INSERT INTO #{table_name} (#{columns(attributes)}) VALUES (#{value_markers(attributes)})"
      end

      def mongodb_to_postgres(name)
        puts("Migrating #{name}.")
        mongodb(name).find.each do |attributes|
          attrs = attributes.except(*SKIP)
          sql = command(name, attrs)
          postgre.create_command(sql).execute_non_query(*values(attrs))
        end
      end

      def mongodb(name)
        @collection ||= Mongoid.master.collection(name)
      end

      def postgre
        @connection ||= DataObjects::Connection.new("postgres://localhost/salesflip_dev")
      end

      def value_markers(attributes = {})
        attributes.size.times.collect{ "?" }.join(",")
      end

      def values(attributes = {})
        attributes.keys.sort.collect { |key| typecast(attributes[key]) }
      end

      def typecast(value)
        case value
        when Array
          value.join(",")
        when BSON::ObjectId
          value.to_s
        else
          value
        end
      end
    end
  end
end
