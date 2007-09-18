class CreateProfiles < ActiveRecord::Migration

  def self.up  
    create_table "profiles", :force => true do |t|
      # entity is a user or a group
      t.column "entity_id",   :integer
      t.column "entity_type", :string
            
      t.column :language, :string,  :limit => 5
      
      # access:
      t.column :all,      :boolean
      t.column :stranger, :boolean
      t.column :peer,     :boolean
      t.column :friend,   :boolean
      t.column :foe,      :boolean

      # people only      
      t.column "name_prefix",     :string
      t.column "first_name",      :string
      t.column "middle_name",     :string
      t.column "last_name",       :string
      t.column "name_suffix",     :string
      t.column "nickname",        :string
      t.column "role",            :string
            
      # people and groups
      t.column "organization",    :string
      t.column "created_at",      :datetime
      t.column "updated_at",      :datetime
      t.column "birthday",        :string, :limit => 8 # to support birthdays before 1971 without weirdness
      t.column "layout_type",     :string
      t.column "layout_data",     :text
    end
    
    add_index "profiles", ["entity_id", "entity_type", "language", "all", "stranger", "peer", "friend", "foe"], :name => "profiles_index"

    create_table "websites", :force => true do |t|
      t.column "profile_id",  :integer
      t.column "preferred",  :boolean, :default => false
      t.column "site_title", :string,  :default => ""
      t.column "site_url",   :string,  :default => ""
    end

    add_index "websites", ["profile_id"], :name => "websites_profile_id_index"
    
    create_table "email_addresses", :force => true do |t|
      t.column "profile_id",    :integer
      t.column "preferred",     :boolean, :default => false
      t.column "email_type",    :string
      t.column "email_address", :string
    end

    add_index "email_addresses", ["profile_id"], :name => "email_addresses_profile_id_index"
        
    create_table "im_addresses", :force => true do |t|
      t.column "profile_id",  :integer
      t.column "preferred",  :boolean, :default => false
      t.column "im_type",    :string
      t.column "im_address", :string
    end

    add_index "im_addresses", ["profile_id"], :name => "im_addresses_profile_id_index"
  
    create_table "locations", :force => true do |t|
      t.column "profile_id",    :integer
      t.column "preferred",     :boolean, :default => false
      t.column "location_type", :string
      t.column "street",        :string
      t.column "city",          :string
      t.column "state",         :string
      t.column "postal_code",   :string
      t.column "geocode",       :string
      t.column "country_name",  :string
    end
  
    add_index "locations", ["profile_id"], :name => "locations_profile_id_index"
        
    create_table "phone_numbers", :force => true do |t|
      t.column "profile_id",        :integer
      t.column "preferred",         :boolean, :default => false
      t.column "provider",          :string
      t.column "phone_number_type", :string  
      t.column "phone_number",      :string  
    end

    add_index "phone_numbers", ["profile_id"], :name => "phone_numbers_profile_id_index"
  
    create_table "profile_notes", :force => true do |t|
      t.column "profile_id",        :integer
      t.column "preferred",         :boolean, :default => false
      t.column "note_type",         :string
      t.column "body",              :text
    end

    add_index "profile_notes", ["profile_id"], :name => "profile_notes_profile_id_index"
  end
  
  def self.down
    drop_table :profiles
    drop_table :websites
    drop_table :phone_numbers
    drop_table :profile_notes
    drop_table :locations
    drop_table :im_addresses
    drop_table :email_addresses
  end
end
