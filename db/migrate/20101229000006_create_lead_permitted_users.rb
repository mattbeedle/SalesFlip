class CreateLeadPermittedUsers < ActiveRecord::Migration
  def self.up
    create_table :lead_permitted_users do |t|
      t.integer :lead_id
      t.integer :permitted_user_id
    end
  end

  def self.down
    drop_table :lead_permitted_users
  end
end
