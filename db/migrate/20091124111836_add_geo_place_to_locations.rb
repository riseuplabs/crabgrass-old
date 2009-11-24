class AddGeoPlaceToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :geo_place_id, :int
  end

  def self.down
    remove_column :locations, :geo_place_id
  end
end
