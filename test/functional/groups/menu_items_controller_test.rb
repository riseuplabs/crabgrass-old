require File.dirname(__FILE__) + '/../../test_helper'

class Groups::MenuItemsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :menu_items, :sites, :profiles, :widgets

  include UrlHelper

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_get_index
    login_as :blue
    get :index, :group_id => 'fai'
    assert_response :success
    assert_not_nil assigns(:menu_items)
  end

  def test_create_menu_item
    login_as :blue
    assert_difference('MenuItem.count') do
      post :create, :group_id => 'fai',
      :menu_item => {:link => "http://test.link", :title => "different title"}
    end
  end

  def test_update_menu_item
    login_as :blue
    put :update, :group_id => 'fai',
      :id => menu_items(:network).id,
      :menu_item => {:link => "http://test.link", :title => "different title"}
    assert_response :redirect
  end

  def test_destroy_menu_item
    login_as :blue
    assert_difference('MenuItem.count', -1) do
      delete :destroy, :group_id => 'fai', :id => menu_items(:tags).id
    end
    assert_response :success
  end
end
