require File.dirname(__FILE__) + '/../test_helper'

class GeoLocationTest < ActiveSupport::TestCase

  def test_country_id_required
    geo_location = GeoLocation.new()
    assert !geo_location.save, "Saved GeoLocation without country id."
  end

end
