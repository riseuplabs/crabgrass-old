require File.dirname(__FILE__) + '/../test_helper'

class WidgetsControllerTest < ActionController::TestCase
  fixtures :groups, :profiles, :widgets, :menu_items, :users, :sites

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_menu_widget_editing
    login_as :blue
    get :edit, :id => widgets(:quickfinder_site2).id
    assert_response :success
    profile = assigns(:profile)
    widget = assigns(:widget)
    root_item = profile.menu_items.find(widget.menu_root_id)
    assert_equal menu_items(:quickfinder_root), root_item
  end


end


