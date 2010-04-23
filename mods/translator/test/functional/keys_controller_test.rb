require File.dirname(__FILE__) + '/../test_helper'

class Translator::KeysControllerTest < ActionController::TestCase
  fixtures :keys, :languages


  def setup
    debugger
    setup_site_with_translator
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:keys)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_show_key
    get :show, :id => keys(:hello).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => keys(:hello).id
    assert_response :success
  end

  def test_should_update_key
    put :update, :id => keys(:hello).id, :key => { }
    assert_redirected_to key_path(assigns(:key))
  end

  def test_should_destroy_key
    assert_difference('Key.count', -1) do
      delete :destroy, :id => keys(:hello).id
    end

    assert_redirected_to keys_path
  end
end
