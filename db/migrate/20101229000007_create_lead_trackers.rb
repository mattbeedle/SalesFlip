class CreateLeadTrackers < ActiveRecord::Migration
  def self.up
    create_table :lead_trackers do |t|
      t.integer :lead_id
      t.integer :tracker_id
    end
  end

  def self.down
    drop_table :lead_trackers
  end
end
