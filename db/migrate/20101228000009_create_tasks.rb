class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :asset_id
      t.integer :assignee_id
      t.integer :completed_by_id
      t.integer :freelancer_id
      t.integer :user_id
      t.string :asset_type

      t.string :legacy_id
      t.string :legacy_asset_id
      t.string :legacy_assignee_id
      t.string :legacy_completed_by_id
      t.string :legacy_freelancer_id
      t.string :legacy_user_id

      # For the Activities mixin.
      t.integer :updater_id
      t.string :legacy_updater_id

      # For the Permissions mixin.
      t.integer :permission
      t.string :legacy_permitted_user_ids
      t.string :permitted_user_ids

      t.boolean :do_not_email
      t.boolean :do_not_log
      t.integer :category
      t.integer :priority
      t.text :name
      t.timestamp :completed_at
      t.timestamp :deleted_at
      t.timestamp :due_at

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
