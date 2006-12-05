class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table "posts", :force => true do |t|
      t.column "user_id",       :integer
      t.column "discussion_id", :integer
      t.column "body",          :text
      t.column "body_html",     :text
      t.column "created_at",    :datetime
      t.column "updated_at",    :datetime
    end
    add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
    add_index "posts", ["discussion_id", "created_at"], :name => "index_posts_on_discussion_id"
  end
  
  def self.down
    drop_table "posts"
  end
end
