require File.dirname(__FILE__) + '/../test_helper'

class Translator::LanguagesControllerTest < ActionController::TestCase
  fixtures :languages, :keys

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
    assert_not_nil assigns(:languages)
  end

  def test_should_get_new
    login_as @translator
    get :new
    assert_response :success
  end

  def test_should_create_language
    login_as @translator
    assert_difference('Language.count') do
      post :create, :language => { }
    end

    assert_redirected_to language_path(assigns(:language))
  end

  def test_should_show_language
    login_as @translator
    get :show, :id => languages(:en).id
    assert_response :success
  end

  def test_should_get_edit
    login_as @translator
    get :edit, :id => languages(:en).id
    assert_response :success
  end

  def test_should_update_language
    login_as @translator
    put :update, :id => languages(:en).id, :language => { }
    assert_redirected_to language_path(assigns(:language))
  end

  def test_should_destroy_language
    login_as @translator
    assert_difference('Language.count', -1) do
      delete :destroy, :id => languages(:en).id
    end

    assert_redirected_to languages_path
  end
end
