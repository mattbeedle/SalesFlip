class MigrateCompanies < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("companies")
  end
  def self.down
    postgre.create_command("DELETE FROM companies").execute_non_query
  end
end
