class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :subject_id
      t.string :subject_type

      t.string :legacy_id
      t.string :legacy_subject_id

      t.string :attachment
      t.string :attachment_filename

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
