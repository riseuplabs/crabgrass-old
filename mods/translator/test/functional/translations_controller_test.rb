require File.dirname(__FILE__) + '/../test_helper'

class TranslationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:translations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_translation
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
    get :show, :id => translations(:hello_en).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => translations(:hello_en).id
    assert_response :success
  end

  def test_should_update_translation
    put :update, :id => translations(:hello_en).id, :translation => { }
    assert_redirected_to translation_path(assigns(:translation))
  end

  def test_should_destroy_translation
    assert_difference('Translation.count', -1) do
      delete :destroy, :id => translations(:hello_en).id
    end

    assert_redirected_to translations_path
  end
end
