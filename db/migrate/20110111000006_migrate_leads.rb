class MigrateLeads < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE leads ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_campaign_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_assignee_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_contact_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_user_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_updater_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_permitted_user_ids text"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE leads ADD COLUMN legacy_tracker_ids text"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("leads")
  end
  def self.down
    postgre.create_command("DELETE FROM leads").execute_non_query
  end
end
