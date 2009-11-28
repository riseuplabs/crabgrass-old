class GeoCountry < ActiveRecord::Base
  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code
  has_many :geo_admin_codes
  has_many :geo_places

  named_scope :with_public_profile, 
    :joins => 'as gc join geo_locations as gl on gc.id = gl.geo_country_id',
    :select => 'gc.name, gc.id'

end
