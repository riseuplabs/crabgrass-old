require File.dirname(__FILE__) + '/../test_helper'

class FooBar < ActiveRecord::Base
  acts_as_map
end

class WooBar < ActiveRecord::Base
  acts_as_map :override_stylesheets => 'style2.css'
end

class ActsAsMapTest < Test::Unit::TestCase
  #load_schema
  
  def test_map_partial
    assert_equal '/locations/map', FooBar.map_partial
    assert_equal '/locations/map', WooBar.map_partial
  end

  def test_no_default_override_stylesheets
    assert_nil FooBar.override_stylesheets
  end

  def test_override_stylesheets
    assert_equal 'style2.css', WooBar.override_stylesheets
  end

end
