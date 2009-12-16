class RemoveProfileIdFromGeoLocation < ActiveRecord::Migration
  def self.up
    remove_column :geo_locations, :profile_id
  end

  def self.down
    add_column :geo_locations, :profile_id, :integer
  end
end
