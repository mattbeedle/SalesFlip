class MigrateAttachments < Migrations::MongodbToPostgresql
  def self.up
    sql = "ALTER TABLE attachments ADD COLUMN attachment_filename varchar(255)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE attachments ADD COLUMN legacy_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE attachments ADD COLUMN legacy_subject_id varchar(24)"
    postgre.create_command(sql).execute_non_query
    sql = "ALTER TABLE attachments ADD COLUMN subject_type varchar(24)"
    postgre.create_command(sql).execute_non_query
    mongodb_to_postgres("attachments")
  end
  def self.down
    postgre.create_command("DELETE FROM attachments").execute_non_query
  end
end
