class AddLatLongAndDirectionsToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :name, :string
    add_column :locations, :latitude, :float
    add_column :locations, :longitude, :float
    add_column :locations, :directions, :string
  end

  def self.down
    remove_column :locations, :name
    remove_column :locations, :latitude
    remove_column :locations, :longitude
    remove_column :locations, :directions
  end
end
