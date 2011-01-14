class AssociateAccounts < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the users...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_user_id"
    sql = "UPDATE accounts SET user_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_assignee_id"
    sql = "UPDATE accounts SET assignee_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the parents...
    subselect = "SELECT id FROM accounts WHERE legacy_id = legacy_parent_id"
    sql = "UPDATE accounts SET parent_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the permissions...
    select = "SELECT id, legacy_permitted_user_ids FROM accounts WHERE legacy_permitted_user_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_permitted_user_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO account_permitted_users (account_id, permitted_user_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}'))"
        postgre.create_command(sql).execute_non_query
      end
    end

    # Migrate the trackers...
    select = "SELECT id, legacy_tracker_ids FROM accounts WHERE legacy_tracker_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_tracker_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO account_trackers (account_id, tracker_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}'))"
        postgre.create_command(sql).execute_non_query
      end
    end
  end

  def self.down
    sql = "UPDATE accounts SET user_id = NULL, assignee_id = NULL, parent_id = NULL"
    postgre.create_command(sql).execute_non_query

    sql = "DELETE FROM account_permitted_users"
    postgre.create_command(sql).execute_non_query

    sql = "DELETE FROM account_trackers"
    postgre.create_command(sql).execute_non_query
  end
end
