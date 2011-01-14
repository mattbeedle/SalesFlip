class AssociateAccounts < Migrations::MongodbToPostgresql

  def self.up
    puts "Associating Accounts."
    # Migrate the users...
    sql = "UPDATE accounts SET user_id = users.id FROM users WHERE users.legacy_id = accounts.legacy_user_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    sql = "UPDATE accounts SET assignee_id = users.id FROM users WHERE users.legacy_id = accounts.legacy_assignee_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the parents...
    sql = "UPDATE accounts SET parent_id = a.id FROM accounts a WHERE a.legacy_id = accounts.legacy_parent_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the permissions...
    select = "SELECT id, legacy_permitted_user_ids FROM accounts WHERE legacy_permitted_user_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_permitted_user_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO account_permitted_users (account_id, permitted_user_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}' LIMIT 1))"
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
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}' LIMIT 1))"
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
