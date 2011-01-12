class AssociateLeads < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the users...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_user_id"
    sql = "UPDATE leads SET user_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the assignees...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_assignee_id"
    sql = "UPDATE leads SET assignee_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the contacts...
    subselect = "SELECT id FROM contacts WHERE legacy_id = legacy_contact_id"
    sql = "UPDATE leads SET contact_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query

    # Migrate the updaters...
    subselect = "SELECT id FROM users WHERE legacy_id = legacy_updater_id"
    sql = "UPDATE leads SET updater_id = (#{subselect})"
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE leads SET user_id = NULL, assignee_id = NULL, contact_id = NULL, updater_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
