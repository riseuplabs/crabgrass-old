class AddDescriptionsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :private_description, :text
    add_column :groups, :public_description, :text
  end

  def self.down
    remove_column :pages, :private_description
    remove_column :pages, :public_description
  end
end
