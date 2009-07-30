require 'test_helper'

class Groups::MenuEntriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:menu_entries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_menu_entry
    assert_difference('MenuEntry.count') do
      post :create, :menu_entry => { }
    end

    assert_redirected_to menu_entry_path(assigns(:menu_entry))
  end

  def test_should_show_menu_entry
    get :show, :id => menu_entries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => menu_entries(:one).id
    assert_response :success
  end

  def test_should_update_menu_entry
    put :update, :id => menu_entries(:one).id, :menu_entry => { }
    assert_redirected_to menu_entry_path(assigns(:menu_entry))
  end

  def test_should_destroy_menu_entry
    assert_difference('MenuEntry.count', -1) do
      delete :destroy, :id => menu_entries(:one).id
    end

    assert_redirected_to menu_entries_path
  end
end
