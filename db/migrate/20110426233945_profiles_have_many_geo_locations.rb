class ProfilesHaveManyGeoLocations < ActiveRecord::Migration
  def self.up
    add_column :geo_locations, :profile_id, :integer
    locations = []
    Profile.find(:all).each do |prof|
      next if prof.geo_location_id.nil?
      gl = GeoLocation.find(prof.geo_location_id) rescue next
      geo_data = {
        :geo_country_id => gl.geo_country_id,
        :geo_admin_code_id => gl.try(:geo_admin_code_id) || nil,
        :geo_place_id => gl.try(:geo_place_id) || nil,
        :profile_id => prof.id
      }
      locations << geo_data
    end
    locations.each do |loc|
      gl = GeoLocation.new(loc)
      gl.save
    end
    remove_column :profiles, :geo_location_id
    execute <<EOSQL
      DELETE from geo_locations where profile_id IS NULL  
EOSQL
  end

  def self.down
    add_column :profiles, :geo_location_id, :integer
    locations = []
    GeoLocation.find(:all).each do |gl|
      geo_data = { :geostuff =>
        [ gl.geo_country_id,
          gl.try(:geo_admin_code_id) || nil,
          gl.try(:geo_place_id) || nil
        ],
        :profile_id => gl.profile_id
      } 
      locations << geo_data
    end
    locations.each do |loc|
      gl = GeoLocation.find_or_create_by_geo_country_id_and_geo_admin_code_id_and_geo_place_id(loc[:geostuff])
      gl.save
      pl = Profile.find(loc[:profile_id])
      pl.geo_location = gl
      pl.save
    end
    execute <<EOSQL
      DELETE from geo_locations where profile_id IS NOT NULL
EOSQL
    remove_column :geo_locations, :profile_id
  end
end
