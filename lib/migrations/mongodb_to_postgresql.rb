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
        attributes.keys.delete_if { |key| key.blank? || key == 'hausnummer' }.sort.collect do |key|
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
          @sql = command(name, attrs)
          postgre.create_command(@sql).execute_non_query(*values(attrs))
        end
      rescue StandardError => e
        puts @sql
        puts e
        raise e
      end

      def mongodb(name)
        @db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db(database)
        if Rails.env.staging?
          @db.authenticate(ENV['MONGODB_STAGING_USER'], ENV['MONGODB_STAGING_PASSWORD'])
        elsif Rails.env.production?
          @db.authenticate(ENV['MONGODB_USER'], ENV['MONGODB_PASSWORD'])
        end
        @collection ||= @db.collection(name)
      end

      def postgre
        @connection ||= DataObjects::Connection.new(
          "postgres://postgres:#{ENV['SALESFLIP_POSTGRES_PASSWORD']}@#{ENV['SALESFLIP_POSTGRES_HOST']}:5432/#{database}")
      end

      def value_markers(attributes = {})
        attributes.delete_if { |k,v| k == 'hausnummer' || k.blank? }.size.times.collect{ "?" }.join(",")
      end

      def values(attributes = {})
        attributes.keys.delete_if { |k| k == 'hausnummer' || k.blank? }.sort.collect { |key| typecast(attributes[key]) }
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
