require File.dirname(__FILE__) + '/../test_helper'

class LanguagesControllerTest < ActionController::TestCase
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
      post :create, :language => { }
    end

    assert_redirected_to language_path(assigns(:language))
  end

  def test_should_show_language
    get :show, :id => languages(:english).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => languages(:english).id
    assert_response :success
  end

  def test_should_update_language
    put :update, :id => languages(:english).id, :language => { }
    assert_redirected_to language_path(assigns(:language))
  end

  def test_should_destroy_language
    assert_difference('Language.count', -1) do
      delete :destroy, :id => languages(:english).id
    end

    assert_redirected_to languages_path
  end
end
