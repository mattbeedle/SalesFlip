class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id
      t.integer :commentable_id
      t.string :commentable_type

      t.string :legacy_id
      t.string :legacy_user_id
      t.string :legacy_commentable_id

      # For the Permissions mixin.
      t.integer :permission
      t.string :legacy_permitted_user_ids
      t.string :permitted_user_ids

      # For the Activities mixin.
      t.integer :updater_id
      t.string :legacy_updater_id

      t.string :subject
      t.text :text
      t.string :from
      t.string :from_email
      t.timestamp :received_at
      t.timestamp :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
