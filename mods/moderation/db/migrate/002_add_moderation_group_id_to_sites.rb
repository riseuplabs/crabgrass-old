class AddModerationGroupIdToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :moderation_group_id, :integer
  end

  def self.down
    remove_column :sites, :moderation_group_id
  end
end
