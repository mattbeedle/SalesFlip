class AssociateContacts < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the users...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_user_id"
    sql = "UPDATE contacts SET user_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the accounts...
    subselect = "SELECT id FROM accounts WHERE legacy_id = legacy_account_id"
    sql = "UPDATE contacts SET account_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_assignee_id"
    sql = "UPDATE contacts SET assignee_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the leads...
    subselect = "SELECT id FROM leads WHERE legacy_id = legacy_lead_id"
    sql = "UPDATE contacts SET lead_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the permissions...
    select = "SELECT id, legacy_permitted_user_ids FROM contacts WHERE legacy_permitted_user_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_permitted_user_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO contact_permitted_users (contact_id, permitted_user_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}'))"
        postgre.create_command(sql).execute_non_query
      end
    end

    # Migrate the trackers...
    select = "SELECT id, legacy_tracker_ids FROM contacts WHERE legacy_tracker_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_tracker_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO contact_trackers (contact_id, tracker_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}'))"
        postgre.create_command(sql).execute_non_query
      end
    end
  end

  def self.down
    sql = "UPDATE contacts SET user_id = NULL, account_id = NULL, assignee_id = NULL, lead_id = NULL"
    postgre.create_command(sql).execute_non_query

    sql = "DELETE FROM contact_permitted_users"
    postgre.create_command(sql).execute_non_query

    sql = "DELETE FROM contact_trackers"
    postgre.create_command(sql).execute_non_query
  end
end
