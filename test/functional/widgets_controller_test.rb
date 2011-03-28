require File.dirname(__FILE__) + '/../test_helper'

class WidgetsControllerTest < ActionController::TestCase
  fixtures :groups, :profiles, :widgets, :menu_items, :users, :sites, :memberships

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
    root_item = widget.menu_items.root
    assert_equal menu_items(:quickfinder_root2), root_item
  end


end


