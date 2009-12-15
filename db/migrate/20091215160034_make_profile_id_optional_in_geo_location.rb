class MakeProfileIdOptionalInGeoLocation < ActiveRecord::Migration
  def self.up
    change_column :geo_locations, 'profile_id', :int, :limit => 11, :null => true
  end

  def self.down
    change_column :geo_locations, 'profile_id', :int, :limit => 11, :null => false
  end
end
