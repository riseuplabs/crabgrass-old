require File.dirname(__FILE__) + '/../test_helper'

class MenuItemsControllerTest < ActionController::TestCase
  fixtures :groups, :profiles, :widgets, :menu_items, :users, :sites, :memberships

  def setup
    enable_site_testing
    @controller.expects(:may_admin_site?).returns(true)
    login_as :blue
  end

  def teardown
    disable_site_testing
  end

  def test_create_without_parent
    qf = widgets(:quickfinder_site2)
    assert_difference 'qf.menu_items.count' do
      post :create, :commit => "Create", :widget_id => qf.id, :menu_item => {
        :title => "Test Menu Entry",
        :link => "http://test.me" }
    end
    assert_response :redirect
    assert_equal nil, qf.menu_items.last.parent
  end

  def test_create_with_parent
    qf = widgets(:quickfinder_site2)
    root = qf.menu_items.root
    assert_difference 'qf.menu_items.count' do
      post :create, :commit => "Create", :widget_id => qf.id, :menu_item => {
        :title => "Test Menu Entry",
        :link => "http://test.me",
        :parent_id => root.id}
    end
    assert_equal root, qf.menu_items.last.parent
    assert_response :success
  end

  def test_edit
    qf = widgets(:quickfinder_site2)
    item = qf.menu_items.root
    get :edit, :widget_id => qf.id, :id => item.id
    assert_response :success
    assert_equal item, assigns(:menu_item)
  end

  def test_update
    qf = widgets(:quickfinder_site2)
    put :update, :widget_id => qf.id,
      :id => menu_items(:quickfinder_root2).id,
      :menu_item => {:link => "http://test.link", :title => "different title"}
    assert_equal "different title", qf.menu_items.root.reload.title
  end

  def test_destroy_with_children
    qf = widgets(:quickfinder_site2)
    assert_difference('MenuItem.count', -3) do
      delete :destroy,
        :widget_id => qf.id,
        :id => menu_items(:quickfinder_root2).id
    end
    assert_response :success
  end
end

