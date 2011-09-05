require File.dirname(__FILE__) + '/../test_helper'

class TrackTest < ActiveSupport::TestCase

  def test_permalink_validation_fails
    track = Track.new
    assert !track.valid?
  end

  def test_permalink_validation_passes
    track = Track.new :permalink_url => 'my url'
    assert track.valid?
  end
end
