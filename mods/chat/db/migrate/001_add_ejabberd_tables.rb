class AddEjabberdTables < ActiveRecord::Migration

  # We need a hostname in order to construct a Jabber ID for each user.
  DOMAIN = UserExtension::DOMAIN

  def self.up
    # TODO: Describe what a roster is
    # TODO: Describe rosterusers table
    create_table "rosterusers" do |t|
      t.string "username",     :limit => 250, :null => false
      t.string "jid",          :limit => 250, :null => false
      t.text   "nick",                        :null => false
      t.string "subscription", :limit => 1,   :null => false
      t.string "ask",          :limit => 1,   :null => false
      t.text   "askmessage",                  :null => false
      t.string "server",       :limit => 1,   :null => false
      t.text   "subscribe",                   :null => false
      t.text   "type"
    end
    add_index "rosterusers", ["username", "jid"], :name => "i_rosteru_user_jid", :unique => true
    add_index "rosterusers", ["username"], :name => "i_rosteru_username"
    add_index "rosterusers", ["jid"], :name => "i_rosteru_jid"

    # TODO: Describe rostergrups table
    create_table "rostergroups" do |t|
      t.string "username", :limit => 250, :null => false
      t.string "jid",      :limit => 250, :null => false
      t.text   "grp",                     :null => false
    end
    add_index "rostergroups", ["username", "jid"], :name => "pk_rosterg_user_jid"

    # Spool queues messages sent to the user while the user was offline
    create_table "spool", :primary_key => "seq", :force => true do |t|
      t.string "username", :limit => 250, :null => false
      t.text   "xml",                     :null => false
    end
    add_index "spool", ["seq"], :name => "seq", :unique => true
    add_index "spool", ["username"], :name => "i_despool"

    # Last - last time user was seen online by ejabberd
    create_table "last", :primary_key => "username", :force => true do |t|
      t.text "seconds", :null => false
      t.text "state",   :null => false
    end

    # TODO: Describe vcard
    create_table "vcard", :primary_key => "username", :force => true do |t|
    t.text "vcard", :null => false
  end

    # TODO: Describe vcard_search
    create_table "vcard_search", :primary_key => "lusername", :force => true do |t|
      t.string "username",  :limit => 250, :null => false
      t.text   "fn",                       :null => false
      t.string "lfn",       :limit => 250, :null => false
      t.text   "family",                   :null => false
      t.string "lfamily",   :limit => 250, :null => false
      t.text   "given",                    :null => false
      t.string "lgiven",    :limit => 250, :null => false
      t.text   "middle",                   :null => false
      t.string "lmiddle",   :limit => 250, :null => false
      t.text   "nickname",                 :null => false
      t.string "lnickname", :limit => 250, :null => false
      t.text   "bday",                     :null => false
      t.string "lbday",     :limit => 250, :null => false
      t.text   "ctry",                     :null => false
      t.string "lctry",     :limit => 250, :null => false
      t.text   "locality",                 :null => false
      t.string "llocality", :limit => 250, :null => false
      t.text   "email",                    :null => false
      t.string "lemail",    :limit => 250, :null => false
      t.text   "orgname",                  :null => false
      t.string "lorgname",  :limit => 250, :null => false
      t.text   "orgunit",                  :null => false
      t.string "lorgunit",  :limit => 250, :null => false
    end
    add_index "vcard_search", ["lfn"], :name => "i_vcard_search_lfn"
    add_index "vcard_search", ["lfamily"], :name => "i_vcard_search_lfamily"
    add_index "vcard_search", ["lgiven"], :name => "i_vcard_search_lgiven"
    add_index "vcard_search", ["lmiddle"], :name => "i_vcard_search_lmiddle"
    add_index "vcard_search", ["lnickname"], :name => "i_vcard_search_lnickname"
    add_index "vcard_search", ["lbday"], :name => "i_vcard_search_lbday"
    add_index "vcard_search", ["lctry"], :name => "i_vcard_search_lctry"
    add_index "vcard_search", ["llocality"], :name => "i_vcard_search_llocality"
    add_index "vcard_search", ["lemail"], :name => "i_vcard_search_lemail"
    add_index "vcard_search", ["lorgname"], :name => "i_vcard_search_lorgname"
    add_index "vcard_search", ["lorgunit"], :name => "i_vcard_search_lorgunit"

    # TODO: Describe privacy_default_list
    create_table "privacy_default_list", :primary_key => "username", :force => true do |t|
      t.string "name", :limit => 250, :null => false
    end

    # TODO: Describe privacy_list
    create_table "privacy_list", :force => true do |t|
      t.string "username", :limit => 250, :null => false
      t.string "name",     :limit => 250, :null => false
    end
    add_index "privacy_list", ["id"], :name => "id", :unique => true
    add_index "privacy_list", ["username", "name"], :name => "i_privacy_list_username_name", :unique => true
    add_index "privacy_list", ["username"], :name => "i_privacy_list_username"

    # TODO: Describe privacy_list_data
    create_table "privacy_list_data", :force => true do |t|
      t.string  "t", :limit => 1, :null => false
      t.text    "value", :null => false
      t.string  "action", :limit => 1, :null => false
      t.integer "ord", :limit => 10, :precision => 10, :scale => 0, :null => false
      t.boolean "match_all",:null => false
      t.boolean "match_iq", :null => false
      t.boolean "match_message", :null => false
      t.boolean "match_presence_in", :null => false
      t.boolean "match_presence_out", :null => false
    end

    # TODO: Describe private_storage
    create_table "private_storage", :id => false, :force => true do |t|
      t.string "username",  :limit => 250, :null => false
      t.string "namespace", :limit => 250, :null => false
      t.text   "data",                     :null => false
    end
    add_index "private_storage", ["username", "namespace"], :name => "i_private_storage_username_namespace", :unique => true
    add_index "private_storage", ["username"], :name => "i_private_storage_username"

    # Create a UserRoster and GroupRoster pair for all already existing contacts.
    Contact.all.each do |contact|
      contact.user.create_user_roster_and_group_roster(contact.contact)
    end
  end

  def self.down
    drop_table :last
    drop_table :privacy_default_list
    drop_table :privacy_list
    drop_table :privacy_list_data
    drop_table :private_storage
    drop_table :rostergroups
    drop_table :rosterusers
    drop_table :spool
    drop_table :vcard
    drop_table :vcard_search
  end
end
