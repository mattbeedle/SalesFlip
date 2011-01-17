module Migrations
  class MongodbToPostgresql

    SKIP = [
      "_sphinx_id",
      "_type",
      "budget",
      "contact_person",
      "do_not_email",
      "do_not_geocode",
      "do_not_log",
      "region",
      "freelancer_id",
      "from_email"
    ]

    class << self
      def columns(attributes = {})
        attributes.keys.sort.collect do |key|
          key =~ /_id/ ? "\"legacy_#{key}\"".gsub("__", "_") : "\"#{key}\""
        end.join(",")
      end

      def command(table_name, attributes = {})
        "INSERT INTO #{table_name} (#{columns(attributes)}) VALUES (#{value_markers(attributes)})"
      end

      def database
        @database ||= DataMapper::Repository.adapters[:default].options["database"]
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
        @collection ||= Mongo::Connection.new.db(database).collection(name)
      end

      def postgre
        @connection ||= DataObjects::Connection.new("postgres://localhost/#{database}")
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