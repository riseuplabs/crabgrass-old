class GeoAdminCode < ActiveRecord::Base
  validates_presence_of :geo_country_id, :admin1_code, :name
  belongs_to :geo_country
  has_many :geo_places

end
