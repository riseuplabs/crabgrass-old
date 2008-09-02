class CreatePageTerms < ActiveRecord::Migration
  def self.up
    remove_column :pages, :delta
    drop_table :auto_summaries
    drop_table :page_indices
    create_table "page_terms", :force => true do |t|
      t.integer  "page_id",               :limit => 11
      t.string   "page_type"
      t.text     "access_ids"

      t.text     "body"
      t.text     "comments"
      t.string   "tags"
      t.string   "title"
 
      t.boolean  "resolved"
      t.integer  "rating"
      t.integer  "contributors_count"
      t.integer  "flow"

      t.string   "group_name"
      t.string   "created_by_login"
      t.string   "updated_by_login"

      t.integer  "group_id",         :limit => 11
      t.integer  "created_by_id",    :limit => 11
      t.integer  "updated_by_id",    :limit => 11

      t.datetime "starts_at"
      t.datetime "ends_at"
      t.datetime "page_updated_at"
      t.datetime "page_created_at"

      t.boolean  "delta"
    end
  end

  def self.down
    add_column :pages, :delta, :boolean
    drop_table :page_terms
    create_table "page_indices", :force => true do |t|
      t.integer  "page_id",               :limit => 11
      t.text     "body"
      t.boolean  "delta"
      t.string   "tags"
      t.text     "entities"
      t.string   "title"
      t.boolean  "resolved"
      t.datetime "page_created_at"
      t.string   "page_created_by_login"
      t.integer  "page_created_by_id",    :limit => 11
      t.datetime "page_updated_at"
      t.string   "page_updated_by_login"
      t.string   "group_name"
      t.datetime "starts_at"
      t.string   "type"
    end
    create_table "auto_summaries", :force => true do |t|
      t.integer "page_id",   :limit => 11
      t.text    "body"
      t.text    "body_html"
      t.boolean "delta"
    end
  end
end

