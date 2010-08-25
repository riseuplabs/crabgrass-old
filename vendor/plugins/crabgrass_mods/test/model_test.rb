require File.dirname(__FILE__) + '/test_helper'

class ModelTest < Test::Unit::TestCase

  load_schema
 
  def test_schema_loaded
    assert_equal [], Crow.all
  end

  # the plugin 'add_feathers' should extend Crow with "has_many :feathers"
  # and the method 'feather_color'

  def test_apply_mixin_to_model
    crow = Crow.new

    assert_equal 'black', crow.feather_color(), 'should allow method definition'
    assert_equal 'squawk', crow.make_sound(), 'should allow method overriding'

    assert_equal [], crow.feathers, 'should allow adding association'
    feather = Feather.new
    crow.feathers << feather
    assert_equal [feather], crow.feathers, 'association should work'
  end

end
