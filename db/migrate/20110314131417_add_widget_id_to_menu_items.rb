class AddWidgetIdToMenuItems < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :widget_id, :integer
  end

  def self.down
    remove_column :menu_items, :widget_id
  end
end
