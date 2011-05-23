class AddShowExpandedGroupWikisToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :show_expanded_group_wikis, :boolean
  end

  def self.down
    remove_column :sites, :show_expanded_group_wikis
  end
end
