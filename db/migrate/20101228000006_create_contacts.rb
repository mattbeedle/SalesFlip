class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :account_id
      t.integer :assignee_id
      t.integer :lead_id
      t.integer :user_id
      t.string :discriminator_type

      t.string :legacy_id
      t.string :legacy_account_id
      t.string :legacy_assignee_id
      t.string :legacy_lead_id
      t.string :legacy_user_id

      # For the Permissions mixin.
      t.integer :permission
      t.string :legacy_permitted_user_ids
      t.string :permitted_user_ids

      # For the Trackable mixin
      t.string :tracker_ids
      t.string :legacy_tracker_ids

      # For the Activities mixin.
      t.integer :updater_id
      t.string :legacy_updater_id

      t.boolean :do_not_call
      t.boolean :do_not_geocode
      t.date :born_on
      t.integer :access
      t.integer :identifier
      t.integer :salutation
      t.integer :source
      t.integer :title
      t.string :address
      t.string :alt_email
      t.string :city
      t.string :country
      t.string :department
      t.string :email
      t.string :facebook
      t.string :fax
      t.string :first_name
      t.string :from
      t.string :job_title
      t.string :last_name
      t.string :full_name
      t.string :linked_in
      t.string :mobile
      t.string :phone
      t.string :postal_code
      t.string :twitter
      t.string :website
      t.string :xing
      t.timestamp :deleted_at
      t.timestamp :received_at

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
