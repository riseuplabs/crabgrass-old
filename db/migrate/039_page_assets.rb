class PageAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :page_id, :integer
    add_column :assets, :created_at, :datetime
  end

  def self.down
    remove_column :assets, :page_id
    remove_column :assets, :created_at
  end
end
