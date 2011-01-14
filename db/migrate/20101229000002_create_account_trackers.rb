class CreateAccountTrackers < ActiveRecord::Migration
  def self.up
    create_table :account_trackers do |t|
      t.integer :account_id
      t.integer :tracker_id
    end
  end

  def self.down
    drop_table :account_trackers
  end
end
