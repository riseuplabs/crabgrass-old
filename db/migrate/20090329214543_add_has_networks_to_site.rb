class AddHasNetworksToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :has_networks, :boolean, :default => true
  end

  def self.down
    remove_column :sites, :has_networks
  end
end
