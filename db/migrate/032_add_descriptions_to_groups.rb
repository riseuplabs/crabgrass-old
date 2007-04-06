class AddDescriptionsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :private_home_id, :integer
    add_column :groups, :public_home_id, :integer
  end

  def self.down
    remove_column :groups, :private_home_id
    remove_column :groups, :public_home_id
  end
end
