require 'test_helper'

class Groups::MenuItemsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:menu_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_menu_item
    assert_difference('MenuItem.count') do
      post :create, :menu_item => { }
    end

    assert_redirected_to menu_item_path(assigns(:menu_item))
  end

  def test_should_show_menu_item
    get :show, :id => menu_items(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => menu_items(:one).id
    assert_response :success
  end

  def test_should_update_menu_item
    put :update, :id => menu_items(:one).id, :menu_item => { }
    assert_redirected_to menu_item_path(assigns(:menu_item))
  end

  def test_should_destroy_menu_item
    assert_difference('MenuItem.count', -1) do
      delete :destroy, :id => menu_items(:one).id
    end

    assert_redirected_to menu_items_path
  end
end
