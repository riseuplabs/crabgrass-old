=begin

=end

class Profile::Location < ActiveRecord::Base
  belongs_to  :profile

  before_save :set_geocode
  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  @@geocode_addresses = false

  def geocode_address
    address_array = [street, city]
    address_array << [state, postal_code].reject(&:blank?) * ' '
    address_array.reject(&:blank?) * ', '
  end

  def lat
    latitude = self.geocode.split(',').first
    latitude.blank? ? nil : latitude.to_f
  end

  def long
    longitude = self.geocode.split(',').last
    longitude.blank? ? nil : longitude.to_f
  end
  
  def url_encoded_geocode_address
    ERB::Util.url_encode(geocode_address)
  end

  def self.options
    %w[Home Work School Other].to_localized_select
  end

  protected

  def validate
    errors.add(nil, "The address can not be entirely blank") if (street.to_s + city.to_s + state.to_s + postal_code.to_s + country_name.to_s).strip.blank?
  end

  # turns an address string into an array of lat/long strings
  def get_geocode_address
    host = 'rpc.geocoder.us'
    path = '/service/csv?address='

    response = Net::HTTP.get_response(host, path + ERB::Util.url_encode(self.geocode_address))
    location = response.body.split(',')[0..1]
    location
  end
  
  def set_geocode
    self.geocode = get_geocode_address.join(',') if @@geocode_addresses
  end

end

