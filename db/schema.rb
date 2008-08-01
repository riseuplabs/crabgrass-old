# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080723045752) do

  create_table "asset_versions", :force => true do |t|
    t.integer  "asset_id",       :limit => 11
    t.integer  "version",        :limit => 11
    t.integer  "parent_id",      :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size",           :limit => 11
    t.integer  "width",          :limit => 11
    t.integer  "height",         :limit => 11
    t.integer  "page_id",        :limit => 11
    t.datetime "created_at"
    t.string   "versioned_type"
    t.datetime "updated_at"
  end

  add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
  add_index "asset_versions", ["parent_id"], :name => "index_asset_versions_parent_id"
  add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
  add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"

  create_table "assets", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",         :limit => 11
    t.integer  "width",        :limit => 11
    t.integer  "height",       :limit => 11
    t.string   "type"
    t.integer  "page_id",      :limit => 11
    t.datetime "created_at"
    t.integer  "version",      :limit => 11
  end

  add_index "assets", ["version"], :name => "index_assets_version"
  add_index "assets", ["page_id"], :name => "index_assets_page_id"

  create_table "auto_summaries", :force => true do |t|
    t.integer "page_id",   :limit => 11
    t.text    "body"
    t.text    "body_html"
    t.boolean "delta"
  end

  create_table "avatars", :force => true do |t|
    t.binary  "image_file_data"
    t.boolean "public",          :default => false
  end

  create_table "categories", :force => true do |t|
  end

  create_table "channels", :force => true do |t|
    t.string  "name"
    t.integer "group_id", :limit => 11
    t.boolean "public",                 :default => false
  end

  add_index "channels", ["group_id"], :name => "index_channels_group_id"

  create_table "channels_users", :force => true do |t|
    t.integer  "channel_id", :limit => 11
    t.integer  "user_id",    :limit => 11
    t.datetime "last_seen"
    t.integer  "status",     :limit => 11
  end

  add_index "channels_users", ["channel_id", "user_id"], :name => "index_channels_users"

  create_table "contacts", :id => false, :force => true do |t|
    t.integer "user_id",    :limit => 11
    t.integer "contact_id", :limit => 11
  end

  add_index "contacts", ["contact_id", "user_id"], :name => "index_contacts"

  create_table "discussions", :force => true do |t|
    t.integer  "posts_count",  :limit => 11, :default => 0
    t.datetime "replied_at"
    t.integer  "replied_by",   :limit => 11
    t.integer  "last_post_id", :limit => 11
    t.integer  "page_id",      :limit => 11
  end

  add_index "discussions", ["page_id"], :name => "index_discussions_page_id"

  create_table "email_addresses", :force => true do |t|
    t.integer "profile_id",    :limit => 11
    t.boolean "preferred",                   :default => false
    t.string  "email_type"
    t.string  "email_address"
  end

  add_index "email_addresses", ["profile_id"], :name => "email_addresses_profile_id_index"

  create_table "events", :force => true do |t|
    t.text    "description"
    t.text    "description_html"
    t.boolean "is_all_day",       :default => false
    t.boolean "is_cancelled",     :default => false
    t.boolean "is_tentative",     :default => true
    t.string  "location"
  end

  create_table "federations", :force => true do |t|
    t.integer "group_id",     :limit => 11
    t.integer "network_id",   :limit => 11
    t.integer "council_id",   :limit => 11
    t.integer "delegates_id", :limit => 11
  end

  create_table "group_participations", :force => true do |t|
    t.integer "group_id", :limit => 11
    t.integer "page_id",  :limit => 11
    t.integer "access",   :limit => 11
  end

  add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "summary"
    t.string   "url"
    t.string   "type"
    t.integer  "parent_id",      :limit => 11
    t.integer  "admin_group_id", :limit => 11
    t.boolean  "council"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avatar_id",      :limit => 11
    t.string   "style"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["parent_id"], :name => "index_groups_parent_id"

  create_table "im_addresses", :force => true do |t|
    t.integer "profile_id", :limit => 11
    t.boolean "preferred",                :default => false
    t.string  "im_type"
    t.string  "im_address"
  end

  add_index "im_addresses", ["profile_id"], :name => "im_addresses_profile_id_index"

  create_table "links", :id => false, :force => true do |t|
    t.integer "page_id",       :limit => 11
    t.integer "other_page_id", :limit => 11
  end

  add_index "links", ["page_id", "other_page_id"], :name => "index_links_page_and_other_page"

  create_table "locations", :force => true do |t|
    t.integer "profile_id",    :limit => 11
    t.boolean "preferred",                   :default => false
    t.string  "location_type"
    t.string  "street"
    t.string  "city"
    t.string  "state"
    t.string  "postal_code"
    t.string  "geocode"
    t.string  "country_name"
  end

  add_index "locations", ["profile_id"], :name => "locations_profile_id_index"

  create_table "memberships", :force => true do |t|
    t.integer  "group_id",   :limit => 11
    t.integer  "user_id",    :limit => 11
    t.integer  "page_id",    :limit => 11
    t.datetime "created_at"
  end

  add_index "memberships", ["group_id", "user_id", "page_id"], :name => "index_memberships"

  create_table "messages", :force => true do |t|
    t.datetime "created_at"
    t.string   "type"
    t.text     "content"
    t.integer  "channel_id",  :limit => 11
    t.integer  "sender_id",   :limit => 11
    t.string   "sender_name"
    t.string   "level"
  end

  add_index "messages", ["channel_id"], :name => "index_messages_on_channel_id"
  add_index "messages", ["sender_id"], :name => "index_messages_channel"

  create_table "page_indices", :force => true do |t|
    t.integer "page_id",            :limit => 11
    t.text    "body"
    t.boolean "delta"
    t.string  "class_display_name"
    t.string  "tags"
  end

  create_table "page_tools", :force => true do |t|
    t.integer "page_id",   :limit => 11
    t.integer "tool_id",   :limit => 11
    t.string  "tool_type"
  end

  add_index "page_tools", ["page_id", "tool_id"], :name => "index_page_tools"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "resolved",                         :default => true
    t.boolean  "public"
    t.integer  "created_by_id",      :limit => 11
    t.integer  "updated_by_id",      :limit => 11
    t.text     "summary"
    t.string   "type"
    t.integer  "message_count",      :limit => 11, :default => 0
    t.integer  "data_id",            :limit => 11
    t.string   "data_type"
    t.integer  "contributors_count", :limit => 11, :default => 0
    t.integer  "posts_count",        :limit => 11, :default => 0
    t.string   "name"
    t.integer  "group_id",           :limit => 11
    t.string   "group_name"
    t.string   "updated_by_login"
    t.string   "created_by_login"
    t.integer  "flow",               :limit => 11
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "delta"
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"
  add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
  add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"
  add_index "pages", ["group_id"], :name => "index_page_group_id"
  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["public"], :name => "index_pages_on_public"
  add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  add_index "pages", ["starts_at"], :name => "index_pages_on_starts_at"
  add_index "pages", ["ends_at"], :name => "index_pages_on_ends_at"

  create_table "phone_numbers", :force => true do |t|
    t.integer "profile_id",        :limit => 11
    t.boolean "preferred",                       :default => false
    t.string  "provider"
    t.string  "phone_number_type"
    t.string  "phone_number"
  end

  add_index "phone_numbers", ["profile_id"], :name => "phone_numbers_profile_id_index"

  create_table "polls", :force => true do |t|
    t.string "type"
  end

  create_table "possibles", :force => true do |t|
    t.string  "name"
    t.text    "action"
    t.integer "poll_id",          :limit => 11
    t.text    "description"
    t.text    "description_html"
    t.integer "position",         :limit => 11
  end

  add_index "possibles", ["poll_id"], :name => "index_possibles_poll_id"

  create_table "posts", :force => true do |t|
    t.integer  "user_id",       :limit => 11
    t.integer  "discussion_id", :limit => 11
    t.text     "body"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["discussion_id", "created_at"], :name => "index_posts_on_discussion_id"

  create_table "profile_notes", :force => true do |t|
    t.integer "profile_id", :limit => 11
    t.boolean "preferred",                :default => false
    t.string  "note_type"
    t.text    "body"
  end

  add_index "profile_notes", ["profile_id"], :name => "profile_notes_profile_id_index"

  create_table "profiles", :force => true do |t|
    t.integer  "entity_id",              :limit => 11
    t.string   "entity_type"
    t.string   "language",               :limit => 5
    t.boolean  "stranger"
    t.boolean  "peer"
    t.boolean  "friend"
    t.boolean  "foe"
    t.string   "name_prefix"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "name_suffix"
    t.string   "nickname"
    t.string   "role"
    t.string   "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "birthday",               :limit => 8
    t.boolean  "fof"
    t.string   "summary"
    t.integer  "wiki_id",                :limit => 11
    t.integer  "photo_id",               :limit => 11
    t.integer  "layout_id",              :limit => 11
    t.boolean  "may_see"
    t.boolean  "may_see_committees"
    t.boolean  "may_see_networks"
    t.boolean  "may_see_members"
    t.boolean  "may_request_membership"
    t.integer  "membership_policy",      :limit => 11
    t.boolean  "may_see_groups"
    t.boolean  "may_see_contacts"
    t.boolean  "may_request_contact"
    t.boolean  "may_pester"
    t.boolean  "may_burden"
    t.boolean  "may_spy"
  end

  add_index "profiles", ["entity_id", "entity_type", "language", "stranger", "peer", "friend", "foe"], :name => "profiles_index"

  create_table "ratings", :force => true do |t|
    t.integer  "rating",        :limit => 11, :default => 0
    t.datetime "created_at",                                  :null => false
    t.string   "rateable_type", :limit => 15, :default => "", :null => false
    t.integer  "rateable_id",   :limit => 11, :default => 0,  :null => false
    t.integer  "user_id",       :limit => 11, :default => 0,  :null => false
  end

  add_index "ratings", ["user_id"], :name => "fk_ratings_user"
  add_index "ratings", ["rateable_type", "rateable_id"], :name => "fk_ratings_rateable"

  create_table "taggings", :force => true do |t|
    t.integer  "taggable_id",   :limit => 11
    t.integer  "tag_id",        :limit => 11
    t.string   "taggable_type"
    t.datetime "created_at"
    t.string   "context"
    t.integer  "tagger_id",     :limit => 11
    t.string   "tagger_type"
  end

  add_index "taggings", ["tag_id"], :name => "tag_id_index"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "taggable_id_index"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "tags_name"

  create_table "task_lists", :force => true do |t|
  end

  create_table "task_participations", :force => true do |t|
    t.boolean "watching"
    t.boolean "waiting"
    t.boolean "assigned"
    t.integer "user_id",  :limit => 11
    t.integer "task_id",  :limit => 11
  end

  create_table "tasks", :force => true do |t|
    t.integer  "task_list_id",     :limit => 11
    t.string   "name"
    t.text     "description"
    t.text     "description_html"
    t.integer  "position",         :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.datetime "due_at"
    t.integer  "created_by_id",    :limit => 11
    t.integer  "updated_by_id",    :limit => 11
    t.integer  "points",           :limit => 11
  end

  add_index "tasks", ["task_list_id"], :name => "index_tasks_task_list_id"
  add_index "tasks", ["task_list_id", "position"], :name => "index_tasks_completed_positions"

  create_table "thumbnails", :force => true do |t|
    t.integer "parent_id",    :limit => 11
    t.string  "parent_type"
    t.string  "content_type"
    t.string  "filename"
    t.string  "name"
    t.integer "size",         :limit => 11
    t.integer "width",        :limit => 11
    t.integer "height",       :limit => 11
    t.boolean "failure"
  end

  create_table "user_participations", :force => true do |t|
    t.integer  "page_id",       :limit => 11
    t.integer  "user_id",       :limit => 11
    t.integer  "folder_id",     :limit => 11
    t.integer  "access",        :limit => 11
    t.datetime "viewed_at"
    t.datetime "changed_at"
    t.boolean  "watch",                       :default => false
    t.boolean  "star"
    t.boolean  "resolved",                    :default => true
    t.boolean  "viewed"
    t.integer  "message_count", :limit => 11, :default => 0
    t.boolean  "attend",                      :default => false
    t.text     "notice"
    t.boolean  "inbox",                       :default => true
  end

  add_index "user_participations", ["page_id"], :name => "index_user_participations_page"
  add_index "user_participations", ["user_id"], :name => "index_user_participations_user"
  add_index "user_participations", ["page_id", "user_id"], :name => "index_user_participations_page_user"
  add_index "user_participations", ["viewed"], :name => "index_user_participations_viewed"
  add_index "user_participations", ["watch"], :name => "index_user_participations_watch"
  add_index "user_participations", ["star"], :name => "index_user_participations_star"
  add_index "user_participations", ["resolved"], :name => "index_user_participations_resolved"
  add_index "user_participations", ["attend"], :name => "index_user_participations_attend"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "display_name"
    t.string   "time_zone"
    t.string   "language",                  :limit => 5
    t.integer  "avatar_id",                 :limit => 11
    t.datetime "last_seen_at"
    t.integer  "version",                   :limit => 11, :default => 0
    t.binary   "direct_group_id_cache"
    t.binary   "all_group_id_cache"
    t.binary   "friend_id_cache"
    t.binary   "foe_id_cache"
    t.binary   "peer_id_cache"
    t.binary   "tag_id_cache"
    t.string   "password_reset_code",       :limit => 40
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

  create_table "votes", :force => true do |t|
    t.integer  "possible_id", :limit => 11
    t.integer  "user_id",     :limit => 11
    t.datetime "created_at"
    t.integer  "value",       :limit => 11
    t.string   "comment"
  end

  add_index "votes", ["possible_id"], :name => "index_votes_possible"
  add_index "votes", ["possible_id", "user_id"], :name => "index_votes_possible_and_user"

  create_table "websites", :force => true do |t|
    t.integer "profile_id", :limit => 11
    t.boolean "preferred",                :default => false
    t.string  "site_title",               :default => ""
    t.string  "site_url",                 :default => ""
  end

  add_index "websites", ["profile_id"], :name => "websites_profile_id_index"

  create_table "wiki_versions", :force => true do |t|
    t.integer  "wiki_id",    :limit => 11
    t.integer  "version",    :limit => 11
    t.text     "body"
    t.text     "body_html"
    t.datetime "updated_at"
    t.integer  "user_id",    :limit => 11
  end

  add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
  add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"

  create_table "wikis", :force => true do |t|
    t.text     "body"
    t.text     "body_html"
    t.datetime "updated_at"
    t.integer  "user_id",      :limit => 11
    t.integer  "lock_version", :limit => 11, :default => 0
    t.datetime "locked_at"
    t.integer  "locked_by_id", :limit => 11
  end

  add_index "wikis", ["user_id"], :name => "index_wikis_user_id"
  add_index "wikis", ["locked_by_id"], :name => "index_wikis_locked_by_id"

end
