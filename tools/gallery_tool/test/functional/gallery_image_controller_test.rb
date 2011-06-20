require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryImageControllerTest < ActionController::TestCase
  fixtures :pages, :users

  def setup
    # make some gallery images? or use fixtures. also needs galleries, maybe fixtures is the way to go.
  end

  def test_new
    login_as :blue
    get :new
    assert_response :success
  end

  def test_create_zip
    login_as :blue
    post :create, :gallery_id => Gallery.find(:first).id, :file => upload_data('subdir.zip')
    assert_response :success  # or does this redirect to the edit page?
  end

  def test_create
    login_as :blue
    post :create, :gallery_id => Gallery.find(:first).id, :file => upload_data('photo.jpg')
    assert_response :success # or does this redirect to the edit page?
  end

  def test_edit
    login_as :blue
    asset = '' ## ??
    get :edit, :id => asset.id
    assert_response :success
    assert assigns(:image).id == asset.id  
  end

  def test_update
    login_as :blue
    asset = '' ## ??
    post :update, :id => asset.id, :title => 'New Title'
    assert_response :success
    assert assigns(:image).title == 'New Title'

    post :update, :id => asset.id, :cover => 1
    assert_response :success
  end

  def test_destroy
    login_as :blue
    gallery = '' ## ??
    assert_difference Asset.count do
      delete :destroy, :id => 1
    end
  end

end
