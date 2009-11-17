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

ActiveRecord::Schema.define(:version => 20091105213521) do

  create_table "activities", :force => true do |t|
    t.integer  "subject_id",   :limit => 11
    t.string   "subject_type"
    t.string   "subject_name"
    t.integer  "object_id",    :limit => 11
    t.string   "object_type"
    t.string   "object_name"
    t.string   "type"
    t.string   "extra"
    t.integer  "key",          :limit => 11
    t.datetime "created_at"
    t.integer  "access",       :limit => 1,  :default => 2
    t.integer  "related_id",   :limit => 11
    t.integer  "site_id",      :limit => 11
    t.boolean  "flag"
  end

  add_index "activities", ["created_at"], :name => "created_at"
  execute "CREATE INDEX subject_0_4_0 ON activities (subject_id,subject_type(4),access)"

  create_table "asset_versions", :force => true do |t|
    t.integer  "asset_id",       :limit => 11
    t.integer  "version",        :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",           :limit => 11
    t.integer  "width",          :limit => 11
    t.integer  "height",         :limit => 11
    t.integer  "page_id",        :limit => 11
    t.datetime "created_at"
    t.string   "versioned_type"
    t.datetime "updated_at"
  end

  add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
  add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
  add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"

  create_table "assets", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",          :limit => 11
    t.integer  "width",         :limit => 11
    t.integer  "height",        :limit => 11
    t.integer  "page_id",       :limit => 11
    t.datetime "created_at"
    t.integer  "version",       :limit => 11
    t.string   "type"
    t.integer  "page_terms_id", :limit => 11
    t.boolean  "is_attachment",               :default => false
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.datetime "updated_at"
    t.string   "caption"
    t.datetime "taken_at"
    t.string   "credit"
  end

  add_index "assets", ["version"], :name => "index_assets_version"
  add_index "assets", ["page_id"], :name => "index_assets_page_id"
  add_index "assets", ["page_terms_id"], :name => "pterms"

  create_table "avatars", :force => true do |t|
    t.binary  "image_file_data"
    t.boolean "public",          :default => false
  end

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken",          :limit => 11
    t.integer  "finished",       :limit => 11
    t.integer  "timeout",        :limit => 11
    t.integer  "priority",       :limit => 11
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
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

  create_table "codes", :force => true do |t|
    t.string   "code",       :limit => 10
    t.integer  "page_id",    :limit => 11
    t.integer  "user_id",    :limit => 11
    t.integer  "access",     :limit => 11
    t.datetime "expires_at"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "codes", ["code"], :name => "index_codes_on_code", :unique => true
  add_index "codes", ["expires_at"], :name => "index_codes_on_expires_at"

  create_table "crypt_keys", :force => true do |t|
    t.integer "profile_id",  :limit => 11
    t.boolean "preferred",                 :default => false
    t.text    "key"
    t.string  "keyring"
    t.string  "fingerprint"
    t.string  "name"
    t.string  "description"
  end

  create_table "custom_appearances", :force => true do |t|
    t.text     "parameters"
    t.integer  "parent_id",         :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "masthead_asset_id", :limit => 11
    t.integer  "favicon_id",        :limit => 11
  end

  create_table "dailies", :force => true do |t|
    t.integer "page_id",    :limit => 11
    t.integer "views",      :limit => 11
    t.integer "stars",      :limit => 11
    t.integer "edits",      :limit => 11
    t.date    "created_at"
  end

  add_index "dailies", ["page_id"], :name => "index_dailies_on_page_id"

  create_table "discussions", :force => true do |t|
    t.integer  "posts_count",      :limit => 11, :default => 0
    t.datetime "replied_at"
    t.integer  "replied_by_id",    :limit => 11
    t.integer  "last_post_id",     :limit => 11
    t.integer  "page_id",          :limit => 11
    t.integer  "commentable_id",   :limit => 11
    t.string   "commentable_type"
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
    t.text     "description"
    t.text     "description_html"
    t.boolean  "is_all_day",       :default => false
    t.boolean  "is_cancelled",     :default => false
    t.boolean  "is_tentative",     :default => true
    t.string   "location"
    t.datetime "starts_at"
    t.datetime "ends_at"
  end

  add_index "events", ["starts_at"], :name => "index_events_on_starts_at"
  add_index "events", ["ends_at"], :name => "index_events_on_ends_at"

  create_table "external_videos", :force => true do |t|
    t.string   "media_key"
    t.string   "media_url"
    t.string   "media_thumbnail_url"
    t.text     "media_embed"
    t.integer  "page_terms_id",       :limit => 11
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "height",              :limit => 3
    t.integer  "width",               :limit => 3
    t.integer  "player",              :limit => 1
  end

  create_table "federatings", :force => true do |t|
    t.integer  "group_id",      :limit => 11
    t.integer  "network_id",    :limit => 11
    t.integer  "council_id",    :limit => 11
    t.integer  "delegation_id", :limit => 11
    t.datetime "created_at"
  end

  add_index "federatings", ["group_id", "network_id"], :name => "gn"
  add_index "federatings", ["network_id", "group_id"], :name => "ng"

  create_table "group_participations", :force => true do |t|
    t.integer  "group_id",          :limit => 11
    t.integer  "page_id",           :limit => 11
    t.integer  "access",            :limit => 11
    t.boolean  "static",                          :default => false
    t.datetime "static_expires"
    t.boolean  "static_expired",                  :default => false
    t.integer  "featured_position", :limit => 11
  end

  add_index "group_participations", ["group_id", "page_id"], :name => "index_group_participations"

  create_table "group_settings", :force => true do |t|
    t.integer "group_id",      :limit => 11
    t.string  "template_data"
    t.string  "allowed_tools"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "url"
    t.string   "type"
    t.integer  "parent_id",  :limit => 11
    t.integer  "council_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avatar_id",  :limit => 11
    t.string   "style"
    t.string   "language",   :limit => 5
    t.integer  "version",    :limit => 11, :default => 0
    t.integer  "min_stars",  :limit => 11, :default => 1
    t.integer  "site_id",    :limit => 11
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["parent_id"], :name => "index_groups_parent_id"

  create_table "hourlies", :force => true do |t|
    t.integer  "page_id",    :limit => 11
    t.integer  "views",      :limit => 11
    t.integer  "stars",      :limit => 11
    t.integer  "edits",      :limit => 11
    t.datetime "created_at"
  end

  add_index "hourlies", ["page_id"], :name => "index_hourlies_on_page_id"

  create_table "im_addresses", :force => true do |t|
    t.integer "profile_id", :limit => 11
    t.boolean "preferred",                :default => false
    t.string  "im_type"
    t.string  "im_address"
  end

  add_index "im_addresses", ["profile_id"], :name => "im_addresses_profile_id_index"

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "rtl",        :default => false
  end

  add_index "languages", ["name", "code"], :name => "languages_index", :unique => true

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
    t.integer  "group_id",     :limit => 11
    t.integer  "user_id",      :limit => 11
    t.datetime "created_at"
    t.boolean  "admin",                      :default => false
    t.datetime "visited_at",                 :default => '1000-01-01 00:00:00', :null => false
    t.integer  "total_visits", :limit => 11, :default => 0
    t.string   "join_method"
  end

  add_index "memberships", ["group_id", "user_id"], :name => "gu"
  add_index "memberships", ["user_id", "group_id"], :name => "ug"

  create_table "menu_items", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.integer  "position",   :limit => 11
    t.integer  "group_id",   :limit => 11
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.datetime "created_at"
    t.string   "type"
    t.text     "content"
    t.integer  "channel_id",  :limit => 11
    t.integer  "sender_id",   :limit => 11
    t.string   "sender_name"
    t.string   "level"
    t.datetime "deleted_at"
    t.integer  "yuck_count",  :limit => 11, :default => 0
    t.boolean  "vetted",                    :default => false
  end

  add_index "messages", ["channel_id"], :name => "index_messages_on_channel_id"
  add_index "messages", ["sender_id"], :name => "index_messages_channel"

  create_table "migrations_info", :force => true do |t|
    t.datetime "created_at"
  end

  create_table "moderated_flags", :force => true do |t|
    t.string   "type",                         :null => false
    t.datetime "vetted_at"
    t.integer  "vetted_by_id",   :limit => 11
    t.datetime "deleted_at"
    t.integer  "deleted_by_id",  :limit => 11
    t.string   "reason_flagged"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",        :limit => 11
    t.integer  "foreign_id",     :limit => 11, :null => false
  end

  create_table "page_histories", :force => true do |t|
    t.integer  "user_id",                     :limit => 11
    t.integer  "page_id",                     :limit => 11
    t.string   "type"
    t.datetime "created_at"
    t.integer  "object_id",                   :limit => 11
    t.string   "object_type"
    t.datetime "notification_sent_at"
    t.datetime "notification_digest_sent_at"
    t.string   "details"
  end

  add_index "page_histories", ["user_id"], :name => "index_page_histories_on_user_id"
  add_index "page_histories", ["object_id", "object_type"], :name => "index_page_histories_on_object_id_and_object_type"
  add_index "page_histories", ["page_id"], :name => "index_page_histories_on_page_id"

  create_table "page_terms", :force => true do |t|
    t.integer  "page_id",            :limit => 11
    t.string   "page_type"
    t.text     "access_ids"
    t.text     "body"
    t.text     "comments"
    t.string   "tags"
    t.string   "title"
    t.boolean  "resolved"
    t.integer  "rating",             :limit => 11
    t.integer  "contributors_count", :limit => 11
    t.integer  "flow",               :limit => 11
    t.string   "created_by_login"
    t.string   "updated_by_login"
    t.integer  "created_by_id",      :limit => 11
    t.integer  "updated_by_id",      :limit => 11
    t.datetime "page_updated_at"
    t.datetime "page_created_at"
    t.boolean  "delta"
    t.string   "media"
    t.integer  "stars_count",        :limit => 11, :default => 0
    t.integer  "views_count",        :limit => 11, :default => 0, :null => false
    t.string   "owner_name"
  end

  add_index "page_terms", ["page_id"], :name => "page_id"
  execute "ALTER TABLE page_terms ENGINE = MyISAM"
  execute "CREATE FULLTEXT INDEX idx_fulltext ON page_terms (access_ids,tags)"

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
    t.string   "updated_by_login"
    t.string   "created_by_login"
    t.integer  "flow",               :limit => 11
    t.integer  "stars_count",        :limit => 11, :default => 0
    t.integer  "views_count",        :limit => 11, :default => 0,     :null => false
    t.integer  "owner_id",           :limit => 11
    t.string   "owner_type"
    t.string   "owner_name"
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.integer  "site_id",            :limit => 11
    t.datetime "happens_at"
    t.integer  "cover_id",           :limit => 11
    t.boolean  "public_requested",                 :default => false
    t.boolean  "vetted",                           :default => false
    t.integer  "yuck_count",         :limit => 11, :default => 0
  end

  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  execute "CREATE INDEX owner_name_4 ON pages (owner_name(4))"
  add_index "pages", ["name", "owner_id"], :name => "index_pages_on_name"

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
    t.datetime "deleted_at"
    t.string   "type"
    t.boolean  "vetted",                      :default => false
    t.integer  "yuck_count",    :limit => 11, :default => 0
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
    t.boolean  "stranger",                             :default => false, :null => false
    t.boolean  "peer",                                 :default => false, :null => false
    t.boolean  "friend",                               :default => false, :null => false
    t.boolean  "foe",                                  :default => false, :null => false
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
    t.datetime "birthday"
    t.boolean  "fof",                                  :default => false, :null => false
    t.text     "summary"
    t.integer  "wiki_id",                :limit => 11
    t.integer  "photo_id",               :limit => 11
    t.integer  "layout_id",              :limit => 11
    t.boolean  "may_see",                              :default => true
    t.boolean  "may_see_committees"
    t.boolean  "may_see_networks"
    t.boolean  "may_see_members"
    t.boolean  "may_request_membership"
    t.integer  "membership_policy",      :limit => 11, :default => 0
    t.boolean  "may_see_groups"
    t.boolean  "may_see_contacts"
    t.boolean  "may_request_contact",                  :default => true
    t.boolean  "may_pester",                           :default => true
    t.boolean  "may_burden"
    t.boolean  "may_spy"
    t.string   "language",               :limit => 5
    t.integer  "discussion_id",          :limit => 11
    t.string   "place"
    t.integer  "video_id",               :limit => 11
    t.text     "summary_html"
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

  create_table "relationships", :force => true do |t|
    t.integer  "user_id",       :limit => 11
    t.integer  "contact_id",    :limit => 11
    t.string   "type",          :limit => 10
    t.integer  "discussion_id", :limit => 11
    t.datetime "visited_at",                  :default => '1000-01-01 00:00:00', :null => false
    t.integer  "unread_count",  :limit => 11, :default => 0
    t.integer  "total_visits",  :limit => 11, :default => 0
  end

  add_index "relationships", ["contact_id", "user_id"], :name => "index_contacts"

  create_table "requests", :force => true do |t|
    t.integer  "created_by_id",         :limit => 11
    t.integer  "approved_by_id",        :limit => 11
    t.integer  "recipient_id",          :limit => 11
    t.string   "recipient_type",        :limit => 5
    t.string   "email"
    t.string   "code",                  :limit => 8
    t.integer  "requestable_id",        :limit => 11
    t.string   "requestable_type",      :limit => 10
    t.integer  "shared_discussion_id",  :limit => 11
    t.integer  "private_discussion_id", :limit => 11
    t.string   "state",                 :limit => 10
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language"
    t.integer  "site_id",               :limit => 11
  end

  execute "CREATE INDEX created_by_0_2 ON requests (created_by_id,state(2))"
  execute "CREATE INDEX recipient_0_2_2 ON requests (recipient_id,recipient_type(2),state(2))"
  execute "CREATE INDEX requestable_0_2_2 ON requests (requestable_id,requestable_type(2),state(2))"
  add_index "requests", ["code"], :name => "code"
  add_index "requests", ["created_at"], :name => "created_at"
  add_index "requests", ["updated_at"], :name => "updated_at"

  create_table "showings", :force => true do |t|
    t.integer "asset_id",         :limit => 11
    t.integer "gallery_id",       :limit => 11
    t.integer "position",         :limit => 11, :default => 0
    t.boolean "is_cover",                       :default => false
    t.integer "stars",            :limit => 11
    t.integer "comment_id_cache", :limit => 11
    t.integer "discussion_id",    :limit => 11
    t.string  "title"
  end

  add_index "showings", ["gallery_id", "asset_id"], :name => "ga"
  add_index "showings", ["asset_id", "gallery_id"], :name => "ag"

  create_table "sites", :force => true do |t|
    t.string  "name"
    t.string  "domain"
    t.string  "email_sender"
    t.integer "pagination_size",        :limit => 11
    t.integer "super_admin_group_id",   :limit => 11
    t.text    "translators"
    t.string  "translation_group"
    t.string  "default_language"
    t.text    "available_page_types"
    t.text    "evil"
    t.boolean "tracking"
    t.boolean "default",                              :default => false
    t.integer "network_id",             :limit => 11
    t.integer "custom_appearance_id",   :limit => 11
    t.boolean "has_networks",                         :default => true
    t.string  "signup_redirect_url"
    t.string  "title"
    t.boolean "enforce_ssl"
    t.boolean "show_exceptions"
    t.boolean "require_user_email"
    t.integer "council_id",             :limit => 11
    t.string  "login_redirect_url"
    t.boolean "chat"
    t.boolean "limited"
    t.integer "signup_mode",            :limit => 1
    t.string  "email_sender_name",      :limit => 40
    t.string  "profiles"
    t.string  "profile_fields"
    t.integer "moderation_group_id",    :limit => 11
    t.boolean "require_user_full_info"
  end

  add_index "sites", ["name"], :name => "index_sites_on_name", :unique => true

  create_table "survey_answers", :force => true do |t|
    t.integer  "question_id",       :limit => 11
    t.integer  "response_id",       :limit => 11
    t.integer  "asset_id",          :limit => 11
    t.text     "value"
    t.string   "type"
    t.datetime "created_at"
    t.integer  "external_video_id", :limit => 11
  end

  create_table "survey_questions", :force => true do |t|
    t.string   "type"
    t.text     "choices"
    t.integer  "survey_id",  :limit => 11
    t.integer  "position",   :limit => 11
    t.string   "label"
    t.text     "details"
    t.boolean  "required"
    t.datetime "created_at"
    t.datetime "expires_at"
    t.string   "regex"
    t.integer  "maximum",    :limit => 11
    t.integer  "minimum",    :limit => 11
    t.boolean  "private",                  :default => false
  end

  create_table "survey_responses", :force => true do |t|
    t.integer  "survey_id",   :limit => 11
    t.integer  "user_id",     :limit => 11
    t.string   "name"
    t.string   "email"
    t.integer  "stars_count", :limit => 11, :default => 0
    t.datetime "created_at"
  end

  create_table "surveys", :force => true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.integer  "responses_count", :limit => 11, :default => 0
    t.string   "settings"
  end

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

  create_table "tasks_users", :id => false, :force => true do |t|
    t.integer "user_id", :limit => 11
    t.integer "task_id", :limit => 11
  end

  add_index "tasks_users", ["user_id", "task_id"], :name => "index_tasks_users_ids"

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

  create_table "tokens", :force => true do |t|
    t.integer  "user_id",    :limit => 11, :null => false
    t.string   "action"
    t.string   "value"
    t.datetime "created_at",               :null => false
  end

  create_table "trackings", :force => true do |t|
    t.integer  "page_id",         :limit => 11
    t.integer  "current_user_id", :limit => 11
    t.integer  "group_id",        :limit => 11
    t.datetime "tracked_at"
    t.boolean  "views"
    t.boolean  "edits"
    t.boolean  "stars"
    t.integer  "user_id",         :limit => 11
  end

  execute "ALTER TABLE trackings ENGINE = MyISAM"

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
    t.boolean  "inbox",                       :default => false
  end

  add_index "user_participations", ["page_id", "user_id"], :name => "page_and_user", :unique => true

  create_table "user_settings", :force => true do |t|
    t.integer  "user_id",                    :limit => 11
    t.string   "email_address"
    t.string   "sms_number"
    t.string   "sms_carrier"
    t.string   "im_address"
    t.string   "im_type"
    t.boolean  "allow_insecure_email",                     :default => false
    t.boolean  "allow_insecure_im",                        :default => false
    t.boolean  "allow_insecure_sms",                       :default => false
    t.integer  "email_crypt_key_id",         :limit => 11
    t.integer  "sms_crypt_key_id",           :limit => 11
    t.boolean  "email_allowed",                            :default => true
    t.boolean  "sms_allowed",                              :default => false
    t.boolean  "im_allowed",                               :default => false
    t.boolean  "receive_digest",                           :default => true
    t.integer  "digest_frequency",           :limit => 11, :default => 2
    t.integer  "digest_day",                 :limit => 11
    t.integer  "preferred_reception_method", :limit => 11, :default => 1
    t.string   "languages_spoken"
    t.integer  "level_of_expertise",         :limit => 11
    t.boolean  "show_welcome",                             :default => true
    t.integer  "login_landing",              :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "preferred_editor",           :limit => 4
  end

  add_index "user_settings", ["user_id"], :name => "index_user_settings_on_user_id"
  add_index "user_settings", ["receive_digest", "digest_frequency", "digest_day"], :name => "digest"

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
    t.integer  "avatar_id",                 :limit => 11
    t.datetime "last_seen_at"
    t.integer  "version",                   :limit => 11, :default => 0
    t.binary   "direct_group_id_cache"
    t.binary   "all_group_id_cache"
    t.binary   "friend_id_cache"
    t.binary   "foe_id_cache"
    t.binary   "peer_id_cache"
    t.binary   "tag_id_cache"
    t.string   "language",                  :limit => 5
    t.binary   "admin_for_group_id_cache"
    t.boolean  "unverified",                              :default => false
    t.string   "receive_notifications"
    t.binary   "student_id_cache"
    t.boolean  "encrypt_emails",                          :default => false
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

  create_table "wiki_locks", :force => true do |t|
    t.integer "wiki_id",      :limit => 11
    t.text    "locks"
    t.integer "lock_version", :limit => 11, :default => 0
  end

  create_table "wiki_versions", :force => true do |t|
    t.integer  "wiki_id",       :limit => 11
    t.integer  "version",       :limit => 11
    t.text     "body"
    t.text     "body_html"
    t.datetime "updated_at"
    t.integer  "user_id",       :limit => 11
    t.text     "raw_structure"
  end

  add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
  add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"

  create_table "wikis", :force => true do |t|
    t.text     "body"
    t.text     "body_html"
    t.datetime "updated_at"
    t.integer  "user_id",       :limit => 11
    t.integer  "version",       :limit => 11
    t.text     "raw_structure"
  end

  add_index "wikis", ["user_id"], :name => "index_wikis_user_id"

end
