class CreateTaskPermittedUsers < ActiveRecord::Migration
  def self.up
    create_table :task_permitted_users do |t|
      t.integer :task_id
      t.integer :permitted_user_id
    end
  end

  def self.down
    drop_table :task_permitted_users
  end
end
