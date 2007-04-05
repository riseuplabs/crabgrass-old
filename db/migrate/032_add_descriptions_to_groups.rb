class AddDescriptionsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :private_description, :text
    add_column :groups, :public_description, :text
  end

  def self.down
    remove_column :groups, :private_description
    remove_column :groups, :public_description
  end
end
