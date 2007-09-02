
class RenameFederations < ActiveRecord::Migration

  def self.up
    rename_table :groups_to_networks, :federations
  end

  def self.down
    rename_table :federations, :group_to_networks
  end
  
end

