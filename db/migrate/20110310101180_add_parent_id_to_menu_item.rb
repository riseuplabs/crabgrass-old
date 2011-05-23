class AddParentIdToMenuItem < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :parent_id, :integer
  end

  def self.down
    remove_column :menu_items, :parent_id
  end
end
