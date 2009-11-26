class GeoLocation < ActiveRecord::Base
  has_one :geo_country
  has_one :geo_admin_code
  has_one :geo_place
  has_one :profile

end
