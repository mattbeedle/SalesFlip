class MigrateComments < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE comments ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE comments ADD COLUMN legacy_user_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE comments ADD COLUMN legacy_commentable_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE comments ADD COLUMN legacy_updater_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE comments ADD COLUMN legacy_permitted_user_ids text"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("comments")
  end
  def self.down
    postgre.create_command("DELETE FROM comments").execute_non_query
  end
end
