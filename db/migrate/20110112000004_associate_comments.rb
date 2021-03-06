class AssociateComments < Migrations::MongodbToPostgresql

  def self.up
    puts "Associating Comments"
    # Migrate the users...
    sql = "UPDATE comments SET user_id = users.id FROM users WHERE users.legacy_id = comments.legacy_user_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the commentables...
    sql = "UPDATE comments SET account_id = accounts.id FROM accounts WHERE " <<
      "comments.commentable_type = 'Account' AND comments.legacy_commentable_id = accounts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE comments SET contact_id = contacts.id FROM contacts WHERE " <<
      "comments.commentable_type = 'Contact' AND comments.legacy_commentable_id = contacts.legacy_id"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE comments SET lead_id = leads.id FROM leads WHERE " <<
      "comments.commentable_type = 'Lead' AND comments.legacy_commentable_id = leads.legacy_id"
    postgre.create_command(sql).execute_non_query

    # Migrate the permissions...
    select = "SELECT id, legacy_permitted_user_ids FROM comments WHERE legacy_permitted_user_ids IS NOT NULL"
    reader = postgre.create_command(select).execute_reader
    reader.each do |row|
      row["legacy_permitted_user_ids"].split(",").each do |id|
        account_id = row["id"]
        sql = "INSERT INTO comment_permitted_users (comment_id, permitted_user_id) " <<
          "values (#{account_id}, (SELECT id FROM users WHERE legacy_id = '#{id}') LIMIT 1)"
        postgre.create_command(sql).execute_non_query
      end
    end

    # Fix type fields
    sql = "UPDATE comments SET type = 'Email' WHERE subject IS NOT NULL"
    postgre.create_command(sql).execute_non_query
    sql = "UPDATE comments SET type = 'Comment' WHERE type IS NULL"
    postgre.create_command(sql).execute_non_query
  end

  def self.down
    sql = "UPDATE comments SET user_id = NULL, commentable_id = NULL"
    postgre.create_command(sql).execute_non_query

    sql = "DELETE FROM comment_permitted_users"
    postgre.create_command(sql).execute_non_query
  end
end
