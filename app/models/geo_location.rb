class GeoLocation < ActiveRecord::Base

  validates_presence_of :geo_country_id
  belongs_to :geo_country

end
