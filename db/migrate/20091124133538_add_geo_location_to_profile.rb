class AddGeoLocationToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :geo_location_id, :int, :limit => 11
  end

  def self.down
    remove_column :profiles, :geo_location_id
  end
end
