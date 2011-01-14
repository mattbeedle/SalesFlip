class CreateCommentPermittedUsers < ActiveRecord::Migration
  def self.up
    create_table :comment_permitted_users do |t|
      t.integer :comment_id
      t.integer :permitted_user_id
    end
  end

  def self.down
    drop_table :comment_permitted_users
  end
end
