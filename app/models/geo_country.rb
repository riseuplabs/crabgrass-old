class GeoCountry < ActiveRecord::Base
  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code
  has_many :geo_admin_codes
  has_many :geo_places
end
