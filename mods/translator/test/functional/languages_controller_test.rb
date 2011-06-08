require File.dirname(__FILE__) + '/../test_helper'

class Translator::LanguagesControllerTest < ActionController::TestCase

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
    assert_not_nil assigns(:languages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_language
    assert_difference('Language.count') do
      post :create, :language => {:name => 'new', :code => 'nu' }
    end

    assert_redirected_to translator_languages_path
  end

  def test_should_show_language
    get :show, :id => 'en'
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 'en'
    assert_response :success
  end

  def test_should_update_language
    put :update, :id => 'en', :language => { :name => 'new', :code => 'nu' }
    assert_redirected_to translator_languages_path
  end

  def test_should_destroy_language
    assert_difference('Language.count', -1) do
      delete :destroy, :id => 'en'
    end

    assert_redirected_to translator_languages_path
  end
end
