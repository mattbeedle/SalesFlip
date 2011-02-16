class AssociateTasks < Migrations::MongodbToPostgresql

  def self.up
    puts "Associating Tasks"
    # Migrate the assets...
    sql = "UPDATE tasks SET account_id = accounts.id FROM accounts WHERE " <<
      "tasks.asset_type = 'Account' AND tasks.legacy_asset_id = accounts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE tasks SET contact_id = contacts.id FROM contacts WHERE " <<
      "tasks.asset_type = 'Contact' AND tasks.legacy_asset_id = contacts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE tasks SET lead_id = leads.id FROM leads WHERE " <<
      "tasks.asset_type = 'Lead' AND tasks.legacy_asset_id = leads.legacy_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the users...
    sql = "UPDATE tasks SET user_id = users.id FROM users WHERE users.legacy_id = tasks.legacy_user_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    sql = "UPDATE tasks SET assignee_id = users.id FROM users WHERE users.legacy_id = tasks.legacy_assignee_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the completed_bys...
    sql = "UPDATE tasks SET completed_by_id = users.id FROM users WHERE users.legacy_id = tasks.legacy_completed_by_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the updaters...
    sql = "UPDATE tasks SET updater_id = users.id FROM users WHERE users.legacy_id = tasks.legacy_updater_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the permissions...
    select = "SELECT id, legacy_permitted_user_ids FROM tasks WHERE legacy_permitted_user_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_permitted_user_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO task_permitted_users (task_id, permitted_user_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}' LIMIT 1))"
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
