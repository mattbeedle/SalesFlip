class MigrateAccounts < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("accounts")
  end
  def self.down
    postgre.create_command("DELETE FROM accounts").execute_non_query
  end
end
