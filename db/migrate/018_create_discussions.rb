class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table "discussions", :force => true do |t|
      t.column "posts_count",  :integer,  :default => 0
      t.column "replied_at",   :datetime
      t.column "replied_by",   :integer
      t.column "last_post_id", :integer
      t.column "page_id", :integer
    end
  end

  def self.down
    drop_table "discussions"
  end
end
