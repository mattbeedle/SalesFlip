class MigrateAttachments < Migrations::MongodbToPostgresql
  def self.up
    mongodb_to_postgres("attachments")
  end
  def self.down
    postgre.create_command("DELETE FROM attachments").execute_non_query
  end
end
