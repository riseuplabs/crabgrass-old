require File.dirname(__FILE__) + '/../test_helper'

class Translator::TranslationsControllerTest < ActionController::TestCase
  fixtures :translations, :keys, :languages, :users

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
    assert_not_nil assigns(:translations)
  end

  def test_should_get_new
    login_as @translator
    get :new
    assert_response :success
  end

  def test_should_create_translation
    login_as @translator
    assert_difference('Translation.count') do
      post :create, :translation => valid_translation
    end
    assert_redirected_to :action => :new

    assert_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:user => nil)
    end
    assert_redirected_to :action => :new
  end

  def test_should_fail_to_create_translation
    login_as @translator
    assert_no_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:text => nil)
    end
    assert_not_nil assigns(:translation).errors

    assert_no_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:language => nil)
    end
    assert_not_nil assigns(:translation).errors

    assert_no_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:key => nil)
    end
    assert_not_nil assigns(:translation).errors
  end


  def test_should_show_translation
    login_as @translator
    get :show, :id => translations(:hello_en).id
    assert_response :success
  end

  def test_should_get_edit
    login_as @translator
    get :edit, :id => translations(:hello_en).id
    assert_response :success
  end

  def test_should_update_translation
    login_as @translator
    put :update, :id => translations(:hello_en).id, :translation => { }
    assert_redirected_to translator_translation_path(assigns(:translation))
  end

  def test_should_destroy_translation
    login_as @translator
    assert_difference('Translation.count', -1) do
      delete :destroy, :id => translations(:hello_en).id
    end

    assert_redirected_to translator_translations_path
  end
end
