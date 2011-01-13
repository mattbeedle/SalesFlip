class CreateContactTrackers < ActiveRecord::Migration
  def self.up
    create_table :contact_trackers do |t|
      t.integer :contact_id
      t.integer :tracker_id
    end
  end

  def self.down
    drop_table :contact_trackers
  end
end
