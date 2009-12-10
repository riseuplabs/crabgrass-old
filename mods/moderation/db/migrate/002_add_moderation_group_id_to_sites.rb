class AddModerationGroupIdToSites < ActiveRecord::Migration
  def self.up
    self.really_up unless Site.columns.collect{|s| s.name}.include?("moderation_group_id")
  end

  def self.really_up
    add_column :sites, :moderation_group_id, :integer
  end

  def self.down
    remove_column :sites, :moderation_group_id
  end
end
