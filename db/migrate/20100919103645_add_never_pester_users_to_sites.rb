class AddNeverPesterUsersToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :never_pester_users, :boolean, :default => false
  end

  def self.down
    remove_column :sites, :never_pester_users
  end
end
