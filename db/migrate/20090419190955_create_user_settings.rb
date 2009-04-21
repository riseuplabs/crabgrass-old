
class CreateUserSettings < ActiveRecord::Migration
  def self.up
    create_table :user_settings do |t|
      t.integer :user_id

      t.string :email_address
      t.string :sms_number
      t.string :sms_carrier
      t.string :im_address
      t.string :im_type

      t.boolean :allow_insecure_email, :default => false
      t.boolean :allow_insecure_im, :default => false
      t.boolean :allow_insecure_sms, :default => false
      t.integer :email_crypt_key_id
      t.integer :sms_crypt_key_id

      t.boolean :email_allowed, :default => true
      t.boolean :sms_allowed, :default => false
      t.boolean :im_allowed, :default => false

      t.boolean :receive_digest, :default => true
      t.integer :digest_frequency, :default => UserSetting::DIGEST[:weekly]
      t.integer :digest_day

      t.integer :preferred_reception_method, :default => UserSetting::METHOD[:email]

      t.string :languages_spoken

      t.integer :level_of_expertise, :default => UserSetting::EXPERTISE[:newby]
      t.boolean :show_welcome, :default => true
      t.integer :login_landing, :default => UserSetting::LANDING[:dashboard]

      t.timestamps
    end
    add_index :user_settings, :user_id
    add_index :user_settings, [:receive_digest, :digest_frequency, :digest_day], :name => :digest
  end

  def self.down
    drop_table :user_settings
  end
end

