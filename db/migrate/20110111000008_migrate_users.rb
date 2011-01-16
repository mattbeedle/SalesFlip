class MigrateUsers < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE users ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE users ADD COLUMN legacy_company_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("users")
  end
  def self.down
    postgre.create_command("DELETE FROM users").execute_non_query
  end
end
