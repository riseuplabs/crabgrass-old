class AddSitesFeaturedFields < ActiveRecord::Migration
  def self.up
    add_column :sites, :featured_fields, :text
  end

  def self.down
    remove_column :sites, :featured_fields
  end
end
