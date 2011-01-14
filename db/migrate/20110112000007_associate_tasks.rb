class AssociateTasks < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the assets...
    sql = "UPDATE tasks SET asset_id = accounts.id FROM accounts WHERE " <<
      "tasks.asset_type = 'Account' AND tasks.legacy_asset_id = accounts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE tasks SET asset_id = contacts.id FROM contacts WHERE " <<
      "tasks.asset_type = 'Contact' AND tasks.legacy_asset_id = contacts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE tasks SET asset_id = leads.id FROM leads WHERE " <<
      "tasks.asset_type = 'Lead' AND tasks.legacy_asset_id = leads.legacy_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the users...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_user_id"
    sql = "UPDATE tasks SET user_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_assignee_id"
    sql = "UPDATE tasks SET assignee_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the compled_bys...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_completed_by_id"
    sql = "UPDATE tasks SET completed_by_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the updaters...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_updater_id"
    sql = "UPDATE tasks SET updater_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the permissions...
    select = "SELECT id, legacy_permitted_user_ids FROM tasks WHERE legacy_permitted_user_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_permitted_user_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO task_permitted_users (task_id, permitted_user_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}'))"
        postgre.create_command(sql).execute_non_query
      end
    end
  end

  def self.down
    sql = "UPDATE tasks SET user_id = NULL, assignee_id = NULL, completed_by_id = NULL, " <<
      "updater_id = NULL, asset_id = NULL"
    postgre.create_command(sql).execute_non_query

    sql = "DELETE FROM task_permitted_users"
    postgre.create_command(sql).execute_non_query
  end
end
