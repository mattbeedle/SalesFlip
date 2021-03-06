# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110112000008) do

  create_table "account_permitted_users", :force => true do |t|
    t.integer "account_id"
    t.integer "permitted_user_id"
  end

  create_table "account_trackers", :force => true do |t|
    t.integer "account_id"
    t.integer "tracker_id"
  end

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assignee_id"
    t.integer  "parent_id"
    t.string   "legacy_id"
    t.string   "legacy_user_id"
    t.string   "legacy_assignee_id"
    t.string   "legacy_parent_id"
    t.integer  "updater_id"
    t.string   "legacy_updater_id"
    t.datetime "deleted_at"
    t.integer  "permission"
    t.string   "legacy_permitted_user_ids"
    t.string   "permitted_user_ids"
    t.string   "tracker_ids"
    t.string   "legacy_tracker_ids"
    t.integer  "access"
    t.integer  "account_type"
    t.integer  "identifier"
    t.text     "billing_address"
    t.string   "email"
    t.string   "facebook"
    t.string   "fax"
    t.string   "linked_in"
    t.string   "name"
    t.string   "phone"
    t.string   "shipping_address"
    t.string   "twitter"
    t.string   "website"
    t.string   "xing"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "notified_user_ids"
    t.string   "legacy_id"
    t.string   "legacy_user_id"
    t.string   "legacy_subject_id"
    t.string   "legacy_notified_user_ids"
    t.integer  "action"
    t.string   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aliases", :id => false, :force => true do |t|
    t.integer "pkid"
    t.string  "mail"
    t.string  "destination"
    t.boolean "enabled"
  end

  create_table "attachments", :force => true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "legacy_id"
    t.string   "legacy_subject_id"
    t.string   "attachment"
    t.string   "attachment_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_permitted_users", :force => true do |t|
    t.integer "comment_id"
    t.integer "permitted_user_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "legacy_id"
    t.string   "legacy_user_id"
    t.string   "legacy_commentable_id"
    t.integer  "permission"
    t.string   "legacy_permitted_user_ids"
    t.string   "permitted_user_ids"
    t.integer  "updater_id"
    t.string   "legacy_updater_id"
    t.string   "subject"
    t.text     "text"
    t.string   "from"
    t.string   "from_email"
    t.datetime "received_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "legacy_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_permitted_users", :force => true do |t|
    t.integer "contact_id"
    t.integer "permitted_user_id"
  end

  create_table "contact_trackers", :force => true do |t|
    t.integer "contact_id"
    t.integer "tracker_id"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "account_id"
    t.integer  "assignee_id"
    t.integer  "lead_id"
    t.integer  "user_id"
    t.string   "discriminator_type"
    t.string   "legacy_id"
    t.string   "legacy_account_id"
    t.string   "legacy_assignee_id"
    t.string   "legacy_lead_id"
    t.string   "legacy_user_id"
    t.integer  "permission"
    t.string   "legacy_permitted_user_ids"
    t.string   "permitted_user_ids"
    t.string   "tracker_ids"
    t.string   "legacy_tracker_ids"
    t.integer  "updater_id"
    t.string   "legacy_updater_id"
    t.boolean  "do_not_call"
    t.boolean  "do_not_geocode"
    t.date     "born_on"
    t.integer  "access"
    t.integer  "identifier"
    t.integer  "salutation"
    t.integer  "source"
    t.integer  "title"
    t.string   "address"
    t.string   "alt_email"
    t.string   "city"
    t.string   "country"
    t.string   "department"
    t.string   "email"
    t.string   "facebook"
    t.string   "fax"
    t.string   "first_name"
    t.string   "from"
    t.string   "job_title"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "linked_in"
    t.string   "mobile"
    t.string   "phone"
    t.string   "postal_code"
    t.string   "twitter"
    t.string   "website"
    t.string   "xing"
    t.datetime "deleted_at"
    t.datetime "received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :id => false, :force => true do |t|
    t.integer "pkid"
    t.string  "domain"
    t.string  "transport"
    t.boolean "enabled"
  end

  create_table "lead_permitted_users", :force => true do |t|
    t.integer "lead_id"
    t.integer "permitted_user_id"
  end

  create_table "lead_trackers", :force => true do |t|
    t.integer "lead_id"
    t.integer "tracker_id"
  end

  create_table "leads", :force => true do |t|
    t.integer  "assignee_id"
    t.integer  "campaign_id"
    t.integer  "contact_id"
    t.integer  "user_id"
    t.string   "legacy_id"
    t.string   "legacy_assignee_id"
    t.string   "legacy_campaign_id"
    t.string   "legacy_contact_id"
    t.string   "legacy_user_id"
    t.integer  "updater_id"
    t.string   "legacy_updater_id"
    t.datetime "deleted_at"
    t.integer  "permission"
    t.string   "legacy_permitted_user_ids"
    t.string   "permitted_user_ids"
    t.string   "tracker_ids"
    t.string   "legacy_tracker_ids"
    t.boolean  "do_not_call"
    t.boolean  "do_not_email"
    t.boolean  "do_not_geocode"
    t.integer  "identifier"
    t.integer  "rating"
    t.integer  "salutation"
    t.integer  "source"
    t.integer  "status"
    t.integer  "title"
    t.string   "address"
    t.string   "alternative_email"
    t.text     "career_site"
    t.string   "city"
    t.string   "company"
    t.string   "company_blog"
    t.string   "company_facebook"
    t.string   "company_phone"
    t.string   "company_twitter"
    t.string   "country"
    t.string   "department"
    t.text     "description"
    t.string   "email"
    t.string   "facebook"
    t.string   "fax"
    t.string   "first_name"
    t.string   "job_title"
    t.string   "last_name"
    t.string   "linked_in"
    t.string   "mobile"
    t.string   "phone"
    t.string   "postal_code"
    t.string   "referred_by"
    t.string   "twitter"
    t.text     "website"
    t.string   "xing"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_permitted_users", :force => true do |t|
    t.integer "task_id"
    t.integer "permitted_user_id"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "assignee_id"
    t.integer  "completed_by_id"
    t.integer  "user_id"
    t.string   "asset_type"
    t.string   "legacy_id"
    t.string   "legacy_asset_id"
    t.string   "legacy_assignee_id"
    t.string   "legacy_completed_by_id"
    t.string   "legacy_user_id"
    t.integer  "updater_id"
    t.string   "legacy_updater_id"
    t.integer  "permission"
    t.string   "legacy_permitted_user_ids"
    t.string   "permitted_user_ids"
    t.boolean  "do_not_email"
    t.boolean  "do_not_log"
    t.integer  "category"
    t.integer  "priority"
    t.text     "name"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "due_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "company_id"
    t.string   "legacy_id"
    t.string   "legacy_company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "failed_attempts"
    t.integer  "role"
    t.integer  "sign_in_count"
    t.string   "api_key"
    t.string   "confirmation_token"
    t.string   "current_sign_in_ip"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "remember_token"
    t.string   "reset_password_token"
    t.string   "type"
    t.string   "unlock_token"
    t.string   "username"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
