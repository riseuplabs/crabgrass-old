=begin

=end

class ProfileGeoLocation < ActiveRecord::Base

  set_table_name 'geo_locations'
  belongs_to  :profile

  def country
    self.geo_country_id
  end
  
  def state 
    self.geo_admin_code_id
  end

  def city
    self.geo_place_id
  end
end
