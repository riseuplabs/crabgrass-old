class AddLimitedToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :limited, :boolean
  end

  def self.down
    remove_column :sites, :limited
  end
end
