class DropLinks < ActiveRecord::Migration
  def self.up
    drop_table :links
  end

  def self.down
    create_table "links", :id => false, :force => true do |t|
      t.integer "page_id",       :limit => 11
      t.integer "other_page_id", :limit => 11
    end
    add_index "links", ["page_id", "other_page_id"], :name => "index_links_page_and_other_page"
  end
end
