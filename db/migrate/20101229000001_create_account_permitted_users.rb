class CreateAccountPermittedUsers < ActiveRecord::Migration
  def self.up
    create_table :account_permitted_users do |t|
      t.integer :account_id
      t.integer :permitted_user_id
    end
  end

  def self.down
    drop_table :account_permitted_users
  end
end
