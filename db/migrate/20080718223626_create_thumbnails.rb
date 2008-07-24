class CreateThumbnails < ActiveRecord::Migration
  def self.up 
    # destroy previous thumbnails
    Asset.delete_all('thumbnail IS NOT NULL')

    # create new thumbnail table
    create_table "thumbnails", :force => true do |t|
      t.integer  "parent_id",    :limit => 11 
      t.string   "parent_type"
      t.string   "content_type"
      t.string   "filename"
      t.string   "name"
      t.integer  "size",         :limit => 11
      t.integer  "width",        :limit => 11
      t.integer  "height",       :limit => 11
      t.boolean  "failure"
    end
    remove_columns :assets, :parent_id, :thumbnail
  end

  def self.down
    drop_table :thumbnails
    add_column :assets, :parent_id, :integer
    add_column :assets, :thumbnail, :string
  end
end

