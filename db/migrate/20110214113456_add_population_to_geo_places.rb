class AddPopulationToGeoPlaces < ActiveRecord::Migration
  def self.up
    add_column :geo_places, :population, :bigint
  end

  def self.down
    remove_column :geo_places, :population
  end
end
