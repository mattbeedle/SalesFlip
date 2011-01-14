class MigrateLeads < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("leads")
  end
  def self.down
    postgre.create_command("DELETE FROM leads").execute_non_query
  end
end
