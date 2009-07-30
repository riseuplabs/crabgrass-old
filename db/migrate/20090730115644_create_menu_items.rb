class CreateMenuItems < ActiveRecord::Migration
  def self.up
    create_table :menu_items do |t|
      t.string :title
      t.string :link
      t.integer :position
      t.integer :group_id
      t.boolean :default

      t.timestamps
    end
  end

  def self.down
    drop_table :menu_items
  end
end
