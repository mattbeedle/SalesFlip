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
  end

  def self.down
    sql = "UPDATE contacts SET user_id = NULL, account_id = NULL, assignee_id = NULL, lead_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
