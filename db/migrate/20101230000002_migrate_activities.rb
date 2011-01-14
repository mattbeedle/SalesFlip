class MigrateActivities < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("activities")
  end
  def self.down
    postgre.create_command("DELETE FROM activities").execute_non_query
  end
end
