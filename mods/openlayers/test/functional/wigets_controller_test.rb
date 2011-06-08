require File.dirname(__FILE__) + '/../test_helper'

class WidgetsControllerTest < ActionController::TestCase
  fixtures :groups, :profiles, :users, :sites, :memberships

  def setup
    enable_site_testing :local
  end

  def teardown
    disable_site_testing
  end

  def test_new_contains_map
    login_as :blue
    get :new
    assert_response :success
    assert_operator assigns(:widget_names), :include?, 'MapWidget'
  end

  def test_create_with_name
    login_as :blue
    post :create, :name => 'MapWidget', :section => '3'
    assert_response :success
    assert assigns(:widget).name = 'MapWidget'
    assert assigns(:widget).section = '3'
  end

  def test_create_step_2
    login_as :blue
    assert_difference "Widget.count" do
      post :create, :name => 'MapWidget', :section => '3', :step => '2'
    end
  end

  def test_show_displays_settings
    login_as :blue
    widget = Widget.create! :name => 'MapWidget',
      :section => 3,
      :profile => Site.current.network.profiles.public,
      :options => {
        :title => 'Hello World!',
        :map_center_longitude => 1.234,
        :map_center_latitude => 4.321,
        :zoomlevel => 'Country Region'
      }
    get :show, :id => widget.id
    assert_response :success
    assert_select 'h3.col-heading', 'Hello World!'
    assert_select 'div#map-container' do
      assert_select 'div#map-center[data-long="1.234"][data-lat="4.321"]'
      assert_select 'div#map-zoom[data-level="4"]'
    end
  end
end

