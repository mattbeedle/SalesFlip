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
  end

  def self.down
    sql = "UPDATE accounts SET user_id = NULL, assignee_id = NULL, parent_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
