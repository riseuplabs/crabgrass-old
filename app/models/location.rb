# Simple class for locations
# will most likely be moved into a location_page extension.

# is used from events already.

class Location < ActiveRecord::Base

  include GeoKit::Geocoders  # for geocoding
  before_save :save_latitude_and_longitude  # attempt to geocode address
  before_validation {|event| state = @state_other if @state_other && (state == 'Other' || state.blank? ) }
  attr_accessor :state_other

  def save_latitude_and_longitude
    address = "#{self.street},#{self.city},#{self.state},#{self.postal_code},#{self.country_name}"
    location = GoogleGeocoder.geocode(address)
    coords = location.ll.scan(/[0-9\.\-\+]+/)
    if coords.length == 2
      self.geocode = location
      self.longitude = coords[1]
      self.latitude = coords[0]
    else
      self.geocode = nil
      self.longitude = nil
      self.latitude = nil
    end
  end
end
