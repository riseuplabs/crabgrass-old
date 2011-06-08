require File.dirname(__FILE__) + '/../test_helper'

class Translator::TranslationsControllerTest < ActionController::TestCase

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
    assert_not_nil assigns(:translations)
  end

  def test_should_get_new
    get :new, :key => 'hello', :site_id => 2, :language => 'fr'
    assert_response :success
  end

  def test_should_create_translation
    assert_difference('Translation.count') do
      post :create, :translation => valid_translation
      assert assigns(:translation).errors.empty?
    end
    assert_response :redirect
  end

  def test_should_fail_to_create_translation
    assert_no_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:text => nil)
    end
    assert_not_nil assigns(:translation).errors

    assert_no_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:key => nil)
    end
    assert_not_nil assigns(:translation).errors

    assert_no_difference('Translation.count') do
      post :create, :translation => valid_translation.merge(:language => nil)
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
    put :update, :id => translations(:hello_en).id,
      :translation => { },
      :save => true
    assert_response :redirect
  end

  def test_should_destroy_translation
    assert_difference('Translation.count', -1) do
      delete :destroy, :id => translations(:hello_en).id
    end
    assert_response :redirect
  end
end
