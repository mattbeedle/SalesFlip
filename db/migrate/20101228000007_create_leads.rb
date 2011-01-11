class CreateLeads < ActiveRecord::Migration
  def self.up
    create_table :leads do |t|
      t.integer :assignee_id
      t.integer :campaign_id
      t.integer :contact_id
      t.integer :freelancer_id
      t.integer :user_id

      t.string :legacy_id
      t.string :legacy_assignee_id
      t.string :legacy_campaign_id
      t.string :legacy_contact_id
      t.string :legacy_freelancer_id
      t.string :legacy_user_id

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

      t.boolean :do_not_call
      t.boolean :do_not_email
      t.boolean :do_not_geocode
      t.integer :identifier
      t.integer :rating
      t.integer :salutation
      t.integer :source
      t.integer :status
      t.integer :title
      t.string :address
      t.string :alternative_email
      t.text :career_site
      t.string :city
      t.string :company
      t.string :company_blog
      t.string :company_facebook
      t.string :company_phone
      t.string :company_twitter
      t.string :country
      t.string :department
      t.text :description
      t.string :email
      t.string :facebook
      t.string :fax
      t.string :first_name
      t.string :job_title
      t.string :last_name
      t.string :linked_in
      t.string :mobile
      t.string :phone
      t.string :postal_code
      t.string :referred_by
      t.string :twitter
      t.text :website
      t.string :xing
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :leads
  end
end
