class AddModerationGroupIdToSites < ActiveRecord::Migration
  def self.up
    unless Site.columns.collect{|p| p.name}.include?("moderation_group_id")
      add_column :sites, :moderation_group_id, :integer
    end
  end

  def self.down
    remove_column :sites, :moderation_group_id
  end
end
