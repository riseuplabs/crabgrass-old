require File.dirname(__FILE__) + '/../test_helper'

class Translator::KeysControllerTest < ActionController::TestCase
  fixtures :keys, :languages


  def setup
    setup_site_with_translator
  end

  def teardown
    disable_site_testing
  end

  def test_should_get_index
    login_as @translator
    get :index
    assert_response :success
    assert_not_nil assigns(:keys)
  end

  def test_should_get_new
    login_as @translator
    get :new
    assert_response :success
  end

  def test_should_show_key
    login_as @translator
    get :show, :id => keys(:hello).to_param
    assert_response :success
  end

  def test_should_get_edit
    login_as @translator
    get :edit, :id => keys(:hello).to_param
    assert_response :success
  end

  def test_should_update_key
    login_as @translator
    put :update, :id => keys(:hello).to_param, :key => { }
    assert_redirected_to translator_key_path(assigns(:key))
  end

  def test_should_destroy_key
    login_as @translator
    assert_difference('Key.count', -1) do
      delete :destroy, :id => keys(:hello).to_param
    end

    assert_redirected_to translator_keys_path
  end
end
