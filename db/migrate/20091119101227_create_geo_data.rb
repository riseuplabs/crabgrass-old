class CreateGeoData < ActiveRecord::Migration
  def self.up
    create_table :geo_countries,
      :options => "DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci" do |t|
      t.column :name, :string, :null => false
      t.column :code, :string, :limit => 3, :null => false 
    end
    create_table :geo_admin_codes,
      :options => "DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci" do |t|
      t.column :geo_country_id, :integer, :null => false
      t.column :admin1_code, :string, :limit => 10, :null => false
      t.column :name, :string, :null => false
    end
    create_table :geo_places,
      :options => "DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci" do |t|
      t.column :geo_country_id, :integer, :null => false
      t.column :geonameid, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :alternatenames, :string, :limit => 5000
      t.column :latitude,  :decimal, :precision => 24, :scale => 20, :null => false
      t.column :longitude, :decimal, :precision => 24, :scale => 20, :null => false
      t.column :geo_admin_code_id, :integer, :null => false
    end
    add_index(:geo_countries, [:name,:code], { :name => 'geo_countries_index', :unique => true })
    add_index(:geo_admin_codes, [:geo_country_id,:admin1_code], {:name => 'geo_admin_codes_index', :unique=>true})
    add_index(:geo_places, :name)
    add_index(:geo_places, :geo_country_id)
    add_index(:geo_places, :geo_admin_code_id)
  end

  def self.down
    drop_table :geo_countries
    drop_table :geo_admin_codes
    drop_table :geo_places
  end
end
