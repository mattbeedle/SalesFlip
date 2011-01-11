class MigrateComments < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("comments")
  end
  def self.down
    postgre.create_command("DELETE FROM comments").execute_non_query
  end
end
