class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id
      t.integer :subject_id
      t.string :subject_type
      t.string :notified_user_ids

      t.string :legacy_id
      t.string :legacy_user_id
      t.string :legacy_subject_id
      t.string :legacy_notified_user_ids

      t.integer :action
      t.string :info

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
