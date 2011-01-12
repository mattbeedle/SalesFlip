class AssociateAttachments < Migrations::MongodbToPostgresql

  def self.up
    # Migrate the subjects...
    sql = "UPDATE attachments SET subject_id = comments.id FROM comments WHERE " <<
      "attachments.subject_type = 'Comment' AND attachments.legacy_subject_id = comments.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE attachments SET subject_id = comments.id FROM comments WHERE " <<
      "attachments.subject_type = 'Email' AND attachments.legacy_subject_id = comments.legacy_id"
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE attachments SET subject_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
