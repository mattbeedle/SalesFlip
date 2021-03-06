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
        attributes.keys.delete_if { |key| key.blank? || key == 'hausnummer' || key == 'unlock_token' }.sort.collect do |key|
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
        if Rails.env.staging?
          @db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db(database)
          @db.authenticate(ENV['MONGODB_STAGING_USER'], ENV['MONGODB_STAGING_PASSWORD'])
        elsif Rails.env.production?
          @db ||= Mongo::Connection.new(ENV['MONGODB_HOST'], 27017).db('salesflip')
          @db.authenticate(ENV['MONGODB_USER'], ENV['MONGODB_PASSWORD'])
        else
          @db = Mongo::Connection.new.db(database)
        end
        @collection ||= @db.collection(name)
      end

      def postgre
        if Rails.env.production? || Rails.env.staging?
          @connection ||= DataObjects::Connection.new(
            "postgres://postgres:#{ENV['SALESFLIP_POSTGRES_PASSWORD']}@#{ENV['SALESFLIP_POSTGRES_HOST']}:5432/#{database}")
        else
          @connection ||= DataObjects::Connection.new(
            "postgres://localhost/#{database}")
        end
        @connection
      end

      def value_markers(attributes = {})
        attributes.delete_if { |k,v| k == 'hausnummer' || k.blank? || k == 'unlock_token' }.size.times.collect{ "?" }.join(",")
      end

      def values(attributes = {})
        attributes.keys.delete_if { |k| k == 'hausnummer' || k.blank? || k == 'unlock_token' }.sort.collect { |key| typecast(attributes[key].blank? ? nil : attributes[key]) }
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
