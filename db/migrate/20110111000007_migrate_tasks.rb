class MigrateTasks < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE tasks ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE tasks ADD COLUMN legacy_asset_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE tasks ADD COLUMN legacy_assignee_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE tasks ADD COLUMN legacy_completed_by_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE tasks ADD COLUMN legacy_user_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE tasks ADD COLUMN legacy_updater_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE tasks ADD COLUMN legacy_permitted_user_ids text"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("tasks")
  end
  def self.down
    postgre.create_command("DELETE FROM tasks").execute_non_query
  end
end
