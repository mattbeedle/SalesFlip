class MigrateTasks < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("tasks")
  end
  def self.down
    postgre.create_command("DELETE FROM tasks").execute_non_query
  end
end
