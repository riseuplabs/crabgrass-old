class AddUsersFeaturedFields < ActiveRecord::Migration
  def self.up
    add_column :users, :featured_fields, :text
  end

  def self.down
    remove_column :users, :featured_fields
  end
end
