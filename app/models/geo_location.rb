class GeoLocation < ActiveRecord::Base
  belongs_to :profile
  has_one :geo_country
  has_one :geo_admin_code
  has_one :geo_place

end
