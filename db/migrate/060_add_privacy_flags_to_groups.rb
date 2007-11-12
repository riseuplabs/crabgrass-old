
class AddPrivacyFlagsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :publicly_visable_group, :boolean
    add_column :groups, :publicly_visable_committees, :boolean
    add_column :groups, :publicly_visable_members, :boolean

    add_column :groups, :accept_new_membership_requests, :boolean
  end

  def self.down
    remove_column :groups, :publicly_visable_group
    remove_column :groups, :publicly_visable_committees
    remove_column :groups, :publicly_visable_members
    
    remove_column :groups, :accept_new_membership_requests
  end
end

