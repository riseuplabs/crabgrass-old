class GroupsToNetworks < ActiveRecord::Migration
  def self.up
    create_table :groups_to_networks do |t|
	  t.column :group_id, :integer
	  t.column :network_id, :integer
	  t.column :council_id, :integer
	  t.column :delegates_id, :integer
	end
  end

  def self.down
    drop_table :groups_to_networks
  end
end
