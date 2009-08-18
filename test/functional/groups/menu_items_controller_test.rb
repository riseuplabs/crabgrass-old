require File.dirname(__FILE__) + '/../../test_helper'

class Groups::MenuItemsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :menu_items

  include UrlHelper

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_should_get_index
    login_as :blue
    get :index, :id => 'fai'
    assert_response :success
    assert_not_nil assigns(:menu_items)
  end

  def test_should_create_menu_item
    #login_as :blue
    #assert_difference('MenuItem.count') do
    #  post :create, :id => 'fai',
    #  :menu_item => {:link => "http://test.link", :title => "different title"}
    #end
  end

  def test_should_update_menu_item
    login_as :blue
    put :update, :id => 'fai', :menu_item_id => 1,
      :menu_item => {:link => "http://test.link", :title => "different title"}
    assert_response :success
  end

  def test_should_destroy_menu_item
    login_as :blue
    assert_difference('MenuItem.count', -1) do
      delete :destroy, :id => 'fai', :menu_item_id => menu_items(:tags).id
    end
    assert_response :success
  end
end
