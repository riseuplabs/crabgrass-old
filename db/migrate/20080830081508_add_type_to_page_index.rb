class AddTypeToPageIndex < ActiveRecord::Migration
  def self.up
    remove_column :page_indices, :class_display_name
    add_column :page_indices, :type, :string
  end

  def self.down
    remove_column :page_indices, :type
    add_column :page_indices, :class_display_name, :string    
  end
end
