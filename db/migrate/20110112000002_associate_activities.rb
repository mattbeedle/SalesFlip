class AssociateActivities < Migrations::MongodbToPostgresql

  def self.up
    puts "Associating Activities"
    # Migrate the users...
    sql = "UPDATE activities SET user_id = users.id FROM users WHERE users.legacy_id = activities.legacy_user_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the subjects...
    sql = "UPDATE activities SET lead_id = leads.id FROM leads WHERE " <<
      "activities.subject_type = 'Lead' AND activities.legacy_subject_id = leads.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET contact_id = contacts.id FROM contacts WHERE " <<
      "activities.subject_type = 'Contact' AND activities.legacy_subject_id = contacts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET account_id = accounts.id FROM accounts WHERE " <<
      "activities.subject_type = 'Account' AND activities.legacy_subject_id = accounts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET user_id = users.id FROM users WHERE " <<
      "activities.subject_type = 'User' AND activities.legacy_subject_id = users.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET comment_id = comments.id FROM comments WHERE " <<
      "activities.subject_type = 'Comment' AND activities.legacy_subject_id = comments.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET task_id = tasks.id FROM tasks WHERE " <<
      "activities.subject_type = 'Task' AND activities.legacy_subject_id = tasks.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE activities SET comment_id = comments.id FROM comments WHERE " <<
      "activities.subject_type = 'Email' AND activities.legacy_subject_id = comments.legacy_id"
    postgre.create_command(sql).execute_non_query

    puts 'Deleting Orphan Activities'
    sql = "DELETE FROM activities where lead_id IS NULL AND contact_id IS NULL AND account_id IS NULL AND user_id IS NULL AND comment_id IS NULL AND task_id IS NULL AND comment_id IS NULL"
    postgre.create_command(sql).execute_non_query

    sql = 'ALTER TABLE activities DROP COLUMN creator_id'
    postgre.create_command(sql).execute_non_query

    puts 'Renaming Activities user_id to creator_id'
    sql = 'ALTER TABLE activities RENAME COLUMN user_id TO creator_id'

    postgre.create_command(sql).execute_non_query
    sql = 'ALTER TABLE activities ALTER COLUMN creator_id SET NOT NULL'
    postgre.create_command(sql).execute_non_query

    puts 'Adding user_id column for datamapper polymorphic stuff'
    sql = 'ALTER TABLE activities ADD COLUMN user_id INTEGER'
    postgre.create_command(sql).execute_non_query

    sql = 'ALTER TABLE activities ALTER COLUMN creator_id SET NOT NULL'
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE activities SET user_id = NULL, lead_id = NULL, contact_id = NULL, " <<
      "account_id = NULL, comment_id = NULL, task_id = NULL"
    postgre.create_command(sql).execute_non_query
  end
end
