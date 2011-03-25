class AddAllProfilesVisibleToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :all_profiles_visible, :boolean
  end

  def self.down
    remove_column :sites, :all_profiles_visible
  end
end
