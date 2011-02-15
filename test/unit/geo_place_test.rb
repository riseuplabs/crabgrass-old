require File.dirname(__FILE__) + '/../test_helper'

class GeoPlaceTest < ActiveSupport::TestCase

  def test_finding_largest
    country = GeoCountry.make
    locations = []
    (1..12).each do |i|
      GeoPlace.make :geo_country => country,
        :population => i*1000,
        :name => "location_#{i}"
    end
    result = country.geo_places.largest(10).all
    assert_equal 10, result.count
    assert_equal "location_12", result[0].name
    assert_equal 12000, result[0].population
    assert_equal "location_3", result[9].name
    assert_equal 3000, result[9].population
  end

  def test_find_by_name
    country = GeoCountry.make
    locations = []
    %w(Berlin Bristol Bern Tokyo).each do |name|
      GeoPlace.make :geo_country => country,
        :population => rand(1000000),
        :name => name
    end
    result = country.geo_places.named_like("B")
    assert_equal 3, result.count
    result = country.geo_places.named_like("Be")
    assert_equal 2, result.count
    assert_equal %w(Berlin Bern), result.map(&:name).sort
  end
end
