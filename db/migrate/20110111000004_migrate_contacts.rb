class MigrateContacts < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE contacts ALTER COLUMN user_id DROP NOT NULL"
    postgre.create_command(sql).execute_non_query

    sql = "ALTER TABLE contacts ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_account_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_assignee_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_lead_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_user_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_updater_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_permitted_user_ids text"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE contacts ADD COLUMN legacy_tracker_ids text"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("contacts")
  end
  def self.down
    postgre.create_command("DELETE FROM contacts").execute_non_query
  end
end
