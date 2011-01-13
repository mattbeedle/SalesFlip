module DataMapper

  # Module defining PostgreSQL-specific extensions for DataMapper resources.
  module Postgres

    # Set up required state on the child model.
    #
    # @api private
    def inherited(descendant)
      super

      descendant.instance_variable_set(:@functions, [])
      descendant.instance_variable_set(:@triggers, [])
      descendant.instance_variable_set(:@views, [])
    end

    # Sets up required state on the extended model.
    #
    # @api private
    def self.extended(model)
      model.instance_variable_set(:@functions, [])
      model.instance_variable_set(:@triggers, [])
      model.instance_variable_set(:@views, [])
    end

    # Defines a new postgres function.
    #
    # @example
    #   function :clear_permissions, args: "id integer" do
    #     <<-SQL
    #     update users set permissions = null where users.id = id;
    #     return null;
    #     SQL
    #   end
    #
    # @example
    #   function :clear_permissions_after_insert, returns: "trigger" do
    #     <<-SQL
    #     perform clear_permissions(new.id);
    #     return null;
    #     SQL
    #   end
    #
    # @param [Symbol] name the name of the function
    # @param [Hash] options the options for the function
    # @param [Proc] block a block which returns the SQL to execute
    # @option options [String] :args (nil) the function's arguments
    # @option options [String] :returns ('void') the function's return value
    # @option options [String] :security ('definer') the function's security
    # @option options [String] :language ('plpgsql') the function's language
    # @option options [String] :execute (nil) the function's body
    #
    # @return [Function] the function object
    #
    # @api public
    def function(name, options = {}, &block)
      Function.new(name, options, &block).tap do |function|
        @functions << function
      end
    end

    # Defines a new trigger for the model.
    #
    # @example
    #   trigger :clear_permissions,
    #     after: :insert,
    #     execute: :clear_permissions_after_insert
    #
    # @param [Symbol] name the name of the trigger
    # @param [Hash] options the options for the trigger
    # @option options [:delete, :insert, :update] :before (nil) when to
    #     execute the trigger
    # @option options [:delete, :insert, :update] :after (nil) when to
    #     execute the trigger
    # @option options [Symbol] :execute (nil) the function to execute for
    #     each row
    #
    # @return [Trigger] the trigger object
    #
    # @api public
    def trigger(name, options = {})
      Trigger.new(name, {on: base_model.name.tableize}.merge(options)).tap do |trigger|
        @triggers << trigger
      end
    end

    # Defines a new postgres view.
    #
    # @example
    #   view :user_ids do
    #     "select id from users"
    #   end
    #
    # @param [Symbol] name the name of the view
    # @param [Hash] options the options for the view
    # @param [Proc] block a block which returns the SQL to execute
    # @option options [String] :execute (nil) the view's body
    #
    # @return [View] the view object
    #
    # @api public
    def view(name, options = {}, &block)
      View.new(name, options, &block).tap do |view|
        @views << view
      end
    end

    class Function
      # @return [Symbol] the function's name
      attr_reader :name

      # @return [Hash] the function's options
      attr_reader :options

      # @return [nil, String] the function's arguments
      attr_reader :args

      # @return [String] the function's return value
      attr_reader :returns

      # @param [Symbol] name the name of the function
      # @param [Hash] options the options for the function
      # @param [Proc] block a block which returns the SQL to execute
      # @option options [String] :args (nil) the function's arguments
      # @option options [String] :returns (nil) the function's return value
      # @option options [String] :security ('definer') the function's security
      # @option options [String] :language ('plpgsql') the function's language
      # @option options [String] :execute (nil) the function's body
      def initialize(name, options = {}, &block)
        @name = name
        @options = options
        @block = block

        normalize_options!
      end

      # Returns the function body necessary for creating the function.
      #
      # @return [String] the function body
      def to_sql
        <<-SQL
        security #{@security}
        language '#{@language}' as $$
        begin
          #{@execute.respond_to?(:call) ? @execute.call : @execute}
        end
        $$
        SQL
      end

      private

      def normalize_options!
        @args     = @options.fetch :args, nil
        @returns  = @options.fetch :returns, 'void'
        @security = @options.fetch :security, 'definer'
        @language = @options.fetch :language, 'plpgsql'
        @execute  = @options.fetch :execute, @block
      end
    end

    class Trigger
      # @return [Symbol] the trigger's name
      attr_reader :name

      # @return [Hash] the trigger's options
      attr_reader :options

      # @return [String] the trigger's target table
      attr_reader :on

      # @return [String] the trigger's scope
      attr_reader :scope

      # @return [String] the procedure to execute
      attr_reader :execute

      # @param [Symbol] name the name of the trigger
      # @param [Hash] options the options for the trigger
      # @option options [String] :on (nil) the table to attach the trigger to
      # @option options [:delete, :insert, :update] :before (nil) when to
      #     execute the trigger
      # @option options [:delete, :insert, :update] :after (nil) when to
      #     execute the trigger
      # @option options [Symbol] :execute (nil) the function to execute for
      #     each row
      def initialize(name, options = {})
        @name = name
        @options = options

        normalize_options!
      end

      private

      def normalize_options!
        @on      = @options.fetch :on
        @scope   = @options[:before] ? "before #{@options[:before]}" : "after #{@options[:after]}"
        @execute = @options.fetch :execute
        @name    = "#{@name}_#{scope.parameterize('_')}"
      end
    end

    class View
      # @return [Symbol] the view's name
      attr_reader :name

      # @param [Symbol] name the name of the view
      # @param [Hash] options the options for the view
      # @param [Proc] block a block which returns the SQL to execute
      # @option options [String] :execute (nil) the view's body
      def initialize(name, options = {}, &block)
        @name = name
        @options = options
        @block = block

        normalize_options!
      end

      # @return [String] the SQL for generating the view
      def to_sql
        @execute.respond_to?(:call) ? @execute.call : @execute
      end

      private

      def normalize_options!
        @execute = @options.fetch :execute, @block
      end
    end


    DataMapper::Adapters::PostgresAdapter.send(:include, Module.new do
      # @api private
      def drop_table_statement(model)
        super << " CASCADE"
      end
    end)


    DataMapper.extend(Module.new do
      def auto_migrate!(repository_name = nil)
        repository_execute :drop_functions!, repository_name
        super
        repository_execute :create_views!, repository_name
        repository_execute :create_functions!, repository_name
        repository_execute :create_triggers!, repository_name
      end
    end)

    # Defines hook methods for migration actions to create and drop views,
    # functions, and triggers as necessary.
    module Migrations

      # Calls DataMapper::Migrations::Model#auto_upgrade! before regenerating
      # the views, functions, and triggers for the model.
      def auto_upgrade!(repository_name = self.repository_name)
        super
      ensure
        create_views!(repository_name)
        create_functions!(repository_name)
        create_triggers!(repository_name)
      end

      private

      def create_views!(repository_name)
        @views.each do |view|
          repository.adapter.create_view(view)
        end
      end

      def create_functions!(repository_name)
        @functions.each do |function|
          repository.adapter.create_function(function)
        end
      end

      def create_triggers!(repository_name)
        @triggers.each do |trigger|
          repository.adapter.create_trigger(trigger)
        end
      end

      def drop_views!(repository_name)
        @views.each do |view|
          repository.adapter.drop_view(view)
        end
      end

      def drop_functions!(repository_name)
        @functions.each do |function|
          repository.adapter.drop_function(function)
        end
      end

      def drop_triggers!(repository_name)
        @triggers.each do |trigger|
          repository.adapter.drop_trigger(trigger)
        end
      end

    end

    include Migrations

    # DataMapper::Adapters::DataObjectsAdapter extension methods for creating
    # and dropping views, functions, and triggers.
    module Adapter

      # Creates a PostgreSQL function.
      #
      # @example
      #   function = Function.new :clear_permissions_after_insert,
      #     returns: "trigger" do
      #       <<-SQL
      #       perform clear_permissions(new.id);
      #       return null;
      #       SQL
      #   end
      #   repository.adapter.create_function(function)
      #   # executes:
      #   #   create or replace function clear_permissions_after_insert()
      #   #     returns trigger
      #   #     security definer
      #   #     language 'plpgsql' as $$
      #   #     begin
      #   #       perform clear_permissions(new.id);
      #   #       return null;
      #   #     end
      #   #     $$
      #
      # @param [Function] function the function to create
      def create_function(function)
        repository.adapter.execute <<-SQL.compress_lines
        create or replace function #{quote_name(function.name)}(
          #{function.args}
        ) returns #{function.returns}
        #{function.to_sql}
        SQL
      end

      # Creates a PostgreSQL trigger.
      #
      # @example
      #   trigger = Trigger.new(:clear_permissions,
      #     on: "users",
      #     after: :insert,
      #     execute: :clear_permissions_after_insert
      #   )
      #   repository.adapter.create_trigger(trigger)
      #   # executes:
      #   #  drop trigger if exists clear_permissions_after_insert on users;
      #   #  create trigger clear_permissions_after_insert
      #   #    after insert
      #   #    on users
      #   #    for each row execute procedure clear_permissions_after_insert();
      #
      # @param [Trigger] trigger the trigger to create
      def create_trigger(trigger)
        repository.adapter.execute <<-SQL.compress_lines
        drop trigger if exists #{quote_name(trigger.name)} on #{quote_name(trigger.on)};
        create trigger #{quote_name(trigger.name)}
          #{trigger.scope}
          on #{quote_name(trigger.on)}
          for each row execute procedure #{trigger.execute}();
        SQL
      end

      # Creates a PostgreSQL view.
      #
      # @example
      #   view = DataMapper::Postgres::View.new(:user_ids) do
      #     "select id from users"
      #   end
      #   repository.adapter.create_view(view)
      #   # executes:
      #   #   create or replace view user_ids as
      #   #   select id from users;
      #
      # @param [View] view the view to create
      def create_view(view)
        repository.adapter.execute <<-SQL.compress_lines
        create or replace view #{quote_name(view.name)} as
        #{view.to_sql}
        SQL
      end

      # Drops a PostgreSQL view.
      #
      # @example
      #   view = DataMapper::Postgres::View.new(:user_ids) do
      #     "select id from users"
      #   end
      #   repository.adapter.drop_view(view)
      #   # executes:
      #   #   drop view if exists user_ids;
      #
      # @param [View] view the view to drop
      def drop_view(view)
        repository.adapter.execute <<-SQL.compress_lines
        drop view if exists #{quote_name(view.name)} cascade
        SQL
      end

      # Drops a PostgreSQL function.
      #
      # @example
      #   function = Function.new(:clear_permissions, args: "id integer")
      #   repository.adapter.drop_function(function)
      #   # executes:
      #   #   drop function if exists clear_permissions(id integer)
      #
      # @param [Function] function the function to drop
      def drop_function(function)
        repository.adapter.execute <<-SQL.compress_lines
        drop function if exists #{quote_name(function.name)}(#{function.args}) cascade
        SQL
      end

      # Drops a PostgreSQL trigger.
      #
      # @example
      #   trigger = Trigger.new(:clear_permissions, User,
      #     after: :insert,
      #     execute: :clear_permissions_after_insert
      #   )
      #   repository.adapter.drop_trigger(trigger)
      #   # executes:
      #   #   drop trigger if exists clear_permissions_after_insert on users;
      #
      # @param [Trigger] trigger the trigger to drop
      def drop_trigger(trigger)
        return unless storage_exists?(trigger.on)

        repository.adapter.execute <<-SQL.compress_lines
        drop trigger if exists #{quote_name(trigger.name)} on #{quote_name(trigger.on)} cascade
        SQL
      end

      DataMapper::Adapters::DataObjectsAdapter.send(:include, self)
    end

    Model.append_extensions self

  end
end
