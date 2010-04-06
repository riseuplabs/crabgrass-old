class CreateGeoLocation < ActiveRecord::Migration
  def self.up
    create_table :geo_locations do |t|
      t.column :geo_country_id, :int, :limit => 11, :null => false
      t.column :geo_admin_code_id, :int, :limit => 11
      t.column :geo_place_id, :int, :limit => 11
      t.column :profile_id, :int, :limit => 11
    end
  end

  def self.down
    drop_table :geo_locations
  end
end
