class AssociateActivities < Migrations::MongodbToPostgresql

  def self.up
    puts "Associating Activities"
    # Migrate the users...
    sql = "UPDATE activities SET user_id = users.id FROM users WHERE users.legacy_id = activities.legacy_user_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the subjects...
    sql = "UPDATE activities SET subject_id = leads.id FROM leads WHERE " <<
      "activities.subject_type = 'Lead' AND activities.legacy_subject_id = leads.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET subject_id = contacts.id FROM contacts WHERE " <<
      "activities.subject_type = 'Contact' AND activities.legacy_subject_id = contacts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET subject_id = accounts.id FROM accounts WHERE " <<
      "activities.subject_type = 'Account' AND activities.legacy_subject_id = accounts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET subject_id = users.id FROM users WHERE " <<
      "activities.subject_type = 'User' AND activities.legacy_subject_id = users.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET subject_id = comments.id FROM comments WHERE " <<
      "activities.subject_type = 'Comment' AND activities.legacy_subject_id = comments.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET subject_id = tasks.id FROM tasks WHERE " <<
      "activities.subject_type = 'Task' AND activities.legacy_subject_id = tasks.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET subject_id = comments.id FROM comments WHERE " <<
      "activities.subject_type = 'Email' AND activities.legacy_subject_id = comments.legacy_id"
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE activities SET user_id = NULL, subject_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
