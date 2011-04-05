class GeoLocation < ActiveRecord::Base

  validates_presence_of :geo_country_id
  belongs_to :geo_country

  named_scope :with_geo_place, :conditions => "geo_place_id != '' and geo_place_id is not null"

end
