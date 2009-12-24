require 'test_helper'

class GeoLocationTest < ActiveSupport::TestCase

  def test_country_id_required
    geo_location = GeoLocation.new(:profile_id => 4)
    assert !geo_location.save, "Saved GeoLocation without country id."
  end

  def test_profile_id_required
    geo_location = GeoLocation.new(:country_id => 1)
    assert !geo_location.save, "Saved GeoLocation without profile id."
  end

end
