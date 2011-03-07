require File.dirname(__FILE__) + '/../test_helper'

class WidgetsTest < ActiveSupport::TestCase

  def setup
    Widget.register "Defaults", {}
    Widget.register "OnlyTitleAndTextWidget",
      :settings => [:title, :text]
    Widget.register "OnlyTitleWidget",
      :settings => [:title]
  end

  def test_registry_defaults
    options = Widget.options["Defaults"]
    expected = { :icon => '/images/widgets/test_me.png',
      :translation => :test_me_widget,
      :description => :test_me_widget_description,
      :settings => [:title],
      :columns => []
    }
    assert_equal expected, options
  end

  def test_only_registered_options_validate
    valid = Widget.new :name => "OnlyTitleAndText",
      :options => {:title => 'Title', :text => 'Lorem Ipsum'}
    invalid = Widget.new :name => "OnlyTitleAndText",
      :options => {:subtitle => 'SubTitle', :text => 'Lorem Ipsum'}
    assert valid.save, "Registered options should validate"
    assert !invalid.save, "Unregistered options should not validate"
  end

  def test_get_widgets_by_container_width
    Widget.register "SingleOnly", :columns => [1]
    Widget.register "DoubleOnly", :columns => [2]
    Widget.register "Both", :columns => [1,2]
    assert_equal ["Both", "SingleOnly"],
      Widget.for_width(1).keys
    assert_equal ["Both", "DoubleOnly"],
      Widget.for_width(2).keys
  end

  def test_options_default_to_empty_hash
    empty = Widget.new "OnlyTitle"
    assert_equal Hash.new, empty.options
  end

  def test_methods_for_registered_options_default_to_nil
    title_and_text = Widget.new :name => "OnlyTitleAndTextWidget",
      :options => {:title => 'Title'}
    assert_nil title_and_text.text
  end

  def test_unregistered_options_raise
    title = Widget.new :name => "OnlyTitleWidget",
      :options => {:title => 'Title'}
    title.text
  end


end
