class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :company_id

      t.string :legacy_id
      t.string :legacy_company_id

      t.string :first_name
      t.string :last_name
      t.integer :failed_attempts
      t.integer :role
      t.integer :sign_in_count
      t.string :api_key
      t.string :confirmation_token
      t.string :current_sign_in_ip
      t.string :email
      t.string :encrypted_password
      t.string :last_sign_in_ip
      t.string :password_salt
      t.string :remember_token
      t.string :reset_password_token
      t.string :type
      t.string :unlock_token
      t.string :username
      t.timestamp :confirmation_sent_at
      t.timestamp :confirmed_at
      t.timestamp :current_sign_in_at
      t.timestamp :last_sign_in_at
      t.timestamp :locked_at
      t.timestamp :remember_created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
