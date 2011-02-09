module Permission
  extend ActiveSupport::Concern

  included do
    through_relationship_name = permitted_users_model.name.tableize.to_sym

    has n, through_relationship_name
    has n, :permitted_users, 'User',
      through: through_relationship_name

    has n, cached_permissions_model.name.tableize.to_sym

    cache_permissions!

    validates_presence_of :permitted_users,
      if: lambda { |model| model.permission_is?('Shared') }

    has_constant :permissions, I18n.t(:permissions, :locale => :en),
      default: 'Public', required: true, auto_validation: true
  end

  def permitted_user_ids=(permitted_user_ids)
    permitted_users.replace(User.all(id: permitted_user_ids))
  end

  def permitted_user_ids
    permitted_users.map &:id
  end

  def permitted_for?(user)
    I18n.locale_around(:en) do
      if !user.role_is?('Freelancer')
        user_id == user.id || permission == 'Public' || assignee_id == user.id ||
          (permission == 'Shared' && permitted_user_ids.include?(user.id)) ||
          (permission == 'Private' && assignee_id == user.id)
      else
        user_id == user.id || (assignee_id == user.id && permission == 'Public') ||
          (assignee_id == user.id && permission == 'Private') ||
          (permission == 'Shared' && permitted_user_ids.include?(user.id) && assignee_id == user.id)
      end
    end
  end

  module ClassMethods

    def permitted_for(user)
      all("#{cached_permissions_model.storage_name}.user_id" => user.id)
    end

    private

    # Creates a model for storing items shared with a user.
    #
    # @example
    #   Lead.permitted_users_model # => LeadPermittedUser
    def permitted_users_model
      model_name = "#{name}PermittedUser"
      return Object.const_get(model_name) if Object.const_defined?(model_name)

      through_model = DataMapper::Model.new(model_name)

      through_model.belongs_to :permitted_user, User, :key => true
      through_model.belongs_to :"#{name.underscore}", :key => true

      through_model
    end

    # Creates a model for storing cached permissions.
    #
    # @example
    #   Lead.cached_permissions_model # => CachedLeadPermission
    def cached_permissions_model
      model_name = "Cached#{name}Permission"
      return Object.const_get(model_name) if Object.const_defined?(model_name)

      model = DataMapper::Model.new(model_name)

      model.belongs_to :"#{name.underscore}", :key => true
      model.belongs_to :user, :key => true

      model
    end

    # Generates view for permissions and functions and triggers for keeping the
    # cached permissions up-to-date.
    def cache_permissions!
      define_uncached_permissions_view!
      define_refresh_cached_permissions_function!
      define_refresh_cached_permissions_triggers!

      define_refresh_triggers_for_permitted_users!
      define_refresh_triggers_for_users!
    end

    # This method defines a simple SQL function on the User model for wrapping
    # the primary refresh function, checking first if "new.id" is defined
    # (insert or update), otherwise using "old.id" (delete).
    #
    # Then it defines triggers for each case -- insert, update, and delete --
    # which will fire off the permissions refresh.
    def define_refresh_triggers_for_users!
      model = User
      cached_permissions = cached_permissions_model.name.tableize
      refresh_function = :"refresh_#{cached_permissions}_on_#{model.name.tableize}"

      model.function refresh_function, returns: "trigger" do
        <<-SQL
        if tg_op = 'INSERT' or tg_op = 'UPDATE' then
          perform refresh_#{cached_permissions}(null, new.id);
        else
          perform refresh_#{cached_permissions}(null, old.id);
        end if;
        return null;
        SQL
      end

      model.trigger :"refresh_#{name.underscore}_permissions",
        after: :insert,
        execute: refresh_function

      model.trigger :"refresh_#{name.underscore}_permissions",
        after: :delete,
        execute: refresh_function

      model.trigger :"refresh_#{name.underscore}_permissions",
        after: :update,
        execute: refresh_function
    end

    # This method defines a simple SQL function on the model which stores the
    # permitted users information (e.g., LeadPermittedUser) for wrapping the
    # primary refresh function, checking first if "new.id" is defined (insert),
    # otherwise using "old.id" (delete).
    #
    # Then it defines triggers for each case -- insert and delete -- which will
    # fire off the permissions refresh.
    def define_refresh_triggers_for_permitted_users!
      model = permitted_users_model                                                         #  model = LeadPermittedUsers
      cached_permissions = cached_permissions_model.name.tableize                           #  cached_permissions = "cached_lead_permissions"
      short_permissions_name = cached_permissions.scan(/^\w|_\w/).join                      #  short_permissions_name = "c_l_p"
      short_table_name = model.name.tableize.scan(/^\w|_\w/).join                           #  short_table_name = "l_p_m"
                                                                                            #
      refresh_function = :"refresh_#{short_permissions_name}_on_#{short_table_name}"        #  refresh_function = :refresh_c_l_p_on_l_p_m
      key = "#{name.underscore}_id"                                                         #  key = "lead_id"
                                                                                            #
      model.function refresh_function,                                                      #  LeadPermittedUsers.function :refresh_c_l_p_on_l_p_m,
        returns: "trigger",                                                                 #    returns: "trigger",
        execute: "if tg_op = 'INSERT' or tg_op = 'UPDATE' then" +                           #    execute: "if tg_op = 'INSERT' or tg_op = 'UPDATE' then
        "  perform refresh_#{cached_permissions}(new.#{key}, new.permitted_user_id); " +    #     perform refresh_cached_lead_permissions(new.lead_id, new.permitted_user_id);
        "else" +                                                                            #   else
        "  perform refresh_#{cached_permissions}(old.#{key}, old.permitted_user_id);" +     #     perform refresh_cached_lead_permissions(old.lead_id, old.permitted_user_id);
        "end if;" +                                                                         #   end if;
        "return null;"                                                                      #   return null;"
                                                                                            #
      model.trigger :"refresh_#{name.underscore}_permissions",                              #  model.trigger :"refresh_lead_permissions",
        after: :insert,                                                                     #    after: :insert,
        execute: refresh_function                                                           #    execute: refresh_c_l_p_on_l_p_m
                                                                                            #
      model.trigger :"refresh_#{name.underscore}_permissions",                              #  model.trigger :"refresh_lead_permissions",
        after: :delete,                                                                     #    after: :delete,
        execute: refresh_function                                                           #    execute: refresh_c_l_p_on_l_p_m
    end

    # This method first defines a simple SQL function for wrapping the primary
    # refresh function, checking first if "new.id" is defined (insert or
    # update), otherwise using "old.id" (delete).
    #
    # Then it defines triggers for each case -- insert, update, and delete --
    # which will fire off the permissions refresh.
    def define_refresh_cached_permissions_triggers!
      cached_permissions = cached_permissions_model.name.tableize
      refresh_function = :"refresh_#{cached_permissions}_on_#{name.tableize}"

      function refresh_function, returns: "trigger" do
        <<-SQL
        if tg_op = 'INSERT' or tg_op = 'UPDATE' then
          perform refresh_#{cached_permissions}(new.id, null);
        else
          perform refresh_#{cached_permissions}(old.id, null);
        end if;
        return null;
        SQL
      end

      trigger :"refresh_#{name.underscore}_permissions",
        after: :insert,
        execute: refresh_function

      trigger :"refresh_#{name.underscore}_permissions",
        after: :delete,
        execute: refresh_function

      trigger :"refresh_#{name.underscore}_permissions",
        after: :update,
        execute: refresh_function
    end

    # This SQL function updates the cached permissions for this model. It
    # accepts two arguments: the model's id, and a user id. When both are
    # present, it only refreshes permissions for that user and lead (e.g., when
    # an entry is inserted into the permitted_users table). When only the
    # source model id is present (e.g., when a lead is created or updated) all
    # permissions for that model are refreshed. Finally, when only the user id
    # is provided, then all permissions for that user are refreshed.
    def define_refresh_cached_permissions_function!
      cached_permissions = cached_permissions_model.name.tableize
      singular_name = name.underscore

      function :"refresh_#{cached_permissions}",
        args: %Q("#{singular_name}" integer, "user" integer),
        execute: <<-SQL
        if #{singular_name} is not null and "user" is not null then
          delete from #{cached_permissions}
           where #{singular_name}_id = #{singular_name}
             and user_id = "user";

          insert into #{cached_permissions}
          select *
            from uncached_#{name.underscore}_permissions
           where #{singular_name}_id = #{singular_name} and user_id = "user";

        elsif #{singular_name} is not null then
          delete from #{cached_permissions}
           where #{singular_name}_id = #{singular_name};

          insert into #{cached_permissions}
          select *
            from uncached_#{name.underscore}_permissions
           where #{singular_name}_id = #{singular_name};

        elsif "user" is not null then
          delete from #{cached_permissions}
           where user_id = "user";

          insert into #{cached_permissions}
          select *
            from uncached_#{name.underscore}_permissions
           where user_id = "user";
        end if;
        SQL
    end


    # This view applies the permissions logic and is equivalent to the
    # following query:
    #
    #     scope =  all(user_id: user.id)
    #     scope |= all(permission: 'Shared', permitted_users.id => user.id)
    #
    #     if Assignable > self
    #       scope |= all(assignee_id: user.id)
    #     end
    #
    #     unless user.role_is?('Freelancer')
    #       scope |= all(permission: 'Public')
    #     end
    #
    #     scope
    #
    def define_uncached_permissions_view!
      key = name.foreign_key
      table_name = name.tableize
      permitted_users_table_name = permitted_users_model.name.tableize

      view :"uncached_#{name.underscore}_permissions" do
        <<-SQL
        select "#{table_name}"."id" as "#{key}",
               "users"."id" as "user_id"
          from "#{table_name}",
               "users"
         where "#{table_name}"."user_id" = "users"."id"
         #{ %Q(or "#{table_name}"."assignee_id" = "users"."id") if Assignable > self }
            or "users"."role" <> #{ROLES.index('Freelancer')+1} and "permission" = #{permissions.index('Public')+1}
            or "#{table_name}"."id" in (
        select "#{table_name}"."id"
          from "#{table_name}"
    inner join "#{permitted_users_table_name}"
            on "#{table_name}"."id" = "#{permitted_users_table_name}"."#{key}"
         where "#{table_name}"."permission" = #{permissions.index('Shared')+1}
           and "#{permitted_users_table_name}"."permitted_user_id" = "users"."id" )
        SQL
      end

    end

  end
end
