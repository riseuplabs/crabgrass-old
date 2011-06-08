require File.dirname(__FILE__) + '/../test_helper'

class OpenLayersWidgetTest < ActiveSupport::TestCase

  def test_widget_registered_for_main_column
    assert Widget.for_columns(2).include? 'MapWidget'
  end

  def test_widget_not_registered_for_sidebar
    assert !Widget.for_columns(1).include?('MapWidget')
  end

end
