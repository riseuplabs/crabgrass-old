require File.dirname(__FILE__) + '/../test_helper'

class WidgetsTest < ActiveSupport::TestCase

  def setup
    Widget.register "DefaultWidget", {}
    Widget.register "OnlyTitleAndTextWidget",
      :settings => [:title, :text]
    Widget.register "OnlyTitleWidget",
      :settings => [:title]
  end

  def test_registry_defaults
    options = Conf.widgets["DefaultWidget"]
    expected = { :icon => '/images/widgets/default.png',
      :translation => :default_widget,
      :description => :default_widget_description,
      :columns => []
    }
    assert_equal expected, options
  end

  def test_registered_options_validate
    widget = Widget.new :name => "OnlyTitleAndTextWidget",
      :profile_id => 1,
      :section => 1,
      :options => {:title => 'Title', :text => 'Lorem Ipsum'}
    assert widget.save
    assert_equal "OnlyTitleAndTextWidget", widget.reload.name
  end

  def test_unregistered_options_are_invalid
    assert_raise ActiveRecord::RecordInvalid do
      invalid = Widget.create! :name => "OnlyTitleAndTextWidget",
        :profile_id => 1,
        :section => 1,
        :options => {:subtitle => 'SubTitle', :text => 'Lorem Ipsum'}
    end
  end

  def test_unregistered_names_are_invalid
    assert_raise ActiveRecord::RecordInvalid do
      invalid = Widget.create! :name => "OnlySubtitleWidget",
        :profile_id => 1,
        :section => 1,
        :options => {:subtitle => 'SubTitle', :text => 'Lorem Ipsum'}
    end
  end

  def test_get_widgets_by_container_width
    Widget.register "SingleOnly", :columns => [1]
    Widget.register "DoubleOnly", :columns => [2]
    Widget.register "Both", :columns => [1,2]
    all = ["Both", "SingleOnly", "DoubleOnly"]
    single = ["Both", "SingleOnly"]
    double = ["Both", "DoubleOnly"]
    assert_equal single, (Widget.for_columns(1).keys & all).sort
    assert_equal double, (Widget.for_columns(2).keys & all).sort
  end

  def test_options_default_to_empty_hash
    empty = Widget.create :name => "OnlyTitle"
    assert_equal Hash.new, empty.options
  end

  def test_methods_for_registered_options_default_to_nil
    title_and_text = Widget.create :name => "OnlyTitleAndTextWidget",
      :options => {:title => 'Title'}
    assert_nil title_and_text.text
  end

  def test_unregistered_options_raise
    title = Widget.create :name => "OnlyTitleWidget",
      :options => {:title => 'Title'}
    assert_raise NoMethodError do
      title.text
    end
  end


end
