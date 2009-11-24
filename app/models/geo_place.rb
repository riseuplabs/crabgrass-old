class GeoPlace < ActiveRecord::Base
  validates_presence_of :geo_country_id, :geo_admin_code_id, :name
  belongs_to :geo_country
  belongs_to :geo_admin_code
end
