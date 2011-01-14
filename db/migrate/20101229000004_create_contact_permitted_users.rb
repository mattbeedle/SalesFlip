class CreateContactPermittedUsers < ActiveRecord::Migration
  def self.up
    create_table :contact_permitted_users do |t|
      t.integer :contact_id
      t.integer :permitted_user_id
    end
  end

  def self.down
    drop_table :contact_permitted_users
  end
end
