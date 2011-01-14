class MigrateContacts < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("contacts")
  end
  def self.down
    postgre.create_command("DELETE FROM contacts").execute_non_query
  end
end
