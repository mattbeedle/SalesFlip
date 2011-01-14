class AssociateContacts < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the users...
    sql = "UPDATE contacts SET user_id = users.id FROM users WHERE users.legacy_id = contacts.legacy_user_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the accounts...
    sql = "UPDATE contacts SET account_id = accounts.id FROM accounts WHERE accounts.legacy_id = contacts.legacy_account_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    sql = "UPDATE contacts SET assignee_id = users.id FROM users WHERE users.legacy_id = contacts.legacy_assignee_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the leads...
    sql = "UPDATE contacts SET lead_id = leads.id FROM leads WHERE leads.legacy_id = contacts.legacy_lead_id"
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
