class MigrateUsers < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("users")
  end
  def self.down
    postgre.create_command("DELETE FROM users").execute_non_query
  end
end
