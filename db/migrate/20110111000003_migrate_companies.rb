class MigrateCompanies < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE companies ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("companies")
  end
  def self.down
    postgre.create_command("DELETE FROM companies").execute_non_query
  end
end
