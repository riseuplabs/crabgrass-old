class AddProfilesAndProfileFieldsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :profiles, :string
    add_column :sites, :profile_fields, :string
  end

  def self.down
    remove_column :sites, :profiles
    remove_column :sites, :profile_fields
  end
end
