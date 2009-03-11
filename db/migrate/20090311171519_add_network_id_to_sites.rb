class AddNetworkIdToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :network_id, :integer
  end

  def self.down
    remove_column :sites, :network_id
  end
end
