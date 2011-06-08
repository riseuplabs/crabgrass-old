require File.dirname(__FILE__) + '/../test_helper'

class Translator::KeysControllerTest < ActionController::TestCase

  def setup
    # animals are translation group...
    enable_site_testing :test
    login_as :penguin
  end

  def teardown
    disable_site_testing
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
    get :show, :id => 'hello'
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 'hello'
    assert_response :success
  end

  def test_should_update_key
    put :update, :id => 'hello', :key => { }, :update => true
    assert_redirected_to translator_key_path(assigns(:key))
  end

  def test_should_destroy_key
    assert_difference('Key.count', -1) do
      delete :destroy, :id => 'hello'
    end

    assert_redirected_to translator_keys_path
  end
end
