#gpg --keyring keyring --no-default-keyring --import public_key.asc
#gpg --keyring keyring --no-default-keyring --encrypt --armor --output outfile.asc --recipient <email> --trust-model always rawfile

class CreateCryptKeys < ActiveRecord::Migration
  def self.up
		create_table "crypt_keys", :force => true do |t|
		  t.integer "profile_id", :limit => 11
		  t.boolean "preferred",  :default => false
		  t.text    "key"       
      t.string  "keyring"
		  t.string  "fingerprint"
      t.string  "name"
      t.string  "description"
		end
  end

  def self.down
    drop_table :crypt_keys
  end
end

