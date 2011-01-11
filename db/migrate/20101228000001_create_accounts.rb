class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :user_id
      t.integer :assignee_id
      t.integer :parent_id

      t.string :legacy_id
      t.string :legacy_user_id
      t.string :legacy_assignee_id
      t.string :legacy_parent_id

      # For the Activities mixin.
      t.integer :updater_id
      t.string :legacy_updater_id

      # For the ParanoidDelete mixin.
      t.timestamp :deleted_at

      # For the Permissions mixin.
      t.integer :permission
      t.string :legacy_permitted_user_ids
      t.string :permitted_user_ids

      # For the Trackable mixin
      t.string :tracker_ids
      t.string :legacy_tracker_ids

      t.integer :access
      t.integer :account_type
      t.integer :identifier
      t.text :billing_address
      t.string :email
      t.string :facebook
      t.string :fax
      t.string :linked_in
      t.string :name
      t.string :phone
      t.string :shipping_address
      t.string :twitter
      t.string :website
      t.string :xing

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
