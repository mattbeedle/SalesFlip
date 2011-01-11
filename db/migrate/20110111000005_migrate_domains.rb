class MigrateDomains < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("domains")
  end
  def self.down
    postgre.create_command("DELETE FROM domains").execute_non_query
  end
end
