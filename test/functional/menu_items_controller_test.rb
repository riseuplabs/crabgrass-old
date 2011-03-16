require File.dirname(__FILE__) + '/../test_helper'

class MenuItemsControllerTest < ActionController::TestCase
  fixtures :groups, :profiles, :widgets, :menu_items, :users, :sites, :memberships

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_index
    login_as :blue
    qf = widgets(:quickfinder_site2)
    get :index, :widget_id => qf.id
    assert_response :success
    assert_not_nil assigns(:menu_items)
  end

  def test_create_without_parent
    login_as :blue
    qf = widgets(:quickfinder_site2)
    assert_difference 'qf.menu_items.count' do
      post :create, :commit => "Create", :widget_id => qf.id, :menu_item => {
        :title => "Test Menu Entry",
        :link => "http://test.me" }
    end
    assert_equal root, qf.menu_items.last.parent
  end

  def test_update
    login_as :blue
    qf = widgets(:quickfinder_site2)
    put :update, :widget_id => qf.id,
      :id => menu_items(:quickfinder_root2).id,
      :menu_item => {:link => "http://test.link", :title => "different title"}
    assert_equal "different title", qf.menu_items.root.reload.title
  end

  def test_destroy
    login_as :blue
    qf = widgets(:quickfinder_site2)
    assert_difference('MenuItem.count', -1) do
      delete :destroy,
        :widget_id => qf.id,
        :id => menu_items(:quickfinder_root2).id
    end
    assert_response :success
  end
end

