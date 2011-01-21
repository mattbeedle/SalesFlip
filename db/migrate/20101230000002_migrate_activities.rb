class MigrateActivities < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE activities ALTER COLUMN user_id DROP NOT NULL"
    postgre.create_command(sql).execute_non_query

    sql = "ALTER TABLE activities ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE activities ADD COLUMN legacy_user_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE activities ADD COLUMN legacy_subject_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE activities ADD COLUMN subject_type varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE activities ADD COLUMN legacy_notified_user_ids text"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("activities")
  end
  def self.down
    postgre.create_command("DELETE FROM activities").execute_non_query
  end
end
