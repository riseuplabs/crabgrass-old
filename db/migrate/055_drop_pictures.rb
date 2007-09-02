
class DropPictures < ActiveRecord::Migration

  def self.up
    drop_table :pictures
  end

  def self.down
      create_table "pictures", :force => true do |t|
      t.column "comment",       :string
      t.column "name",          :string
      t.column "content_type",  :string
      t.column "data",          :binary
      t.column "created_by_id", :integer
      t.column "created_at",    :datetime
      t.column "thumb",         :binary
      t.column "type",          :string
    end
    add_index "pictures", ["created_by_id"], :name => "index_pictures_created_by_id"
  end
  
end

