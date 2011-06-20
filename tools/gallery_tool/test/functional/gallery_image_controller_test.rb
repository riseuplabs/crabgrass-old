require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryImageControllerTest < ActionController::TestCase
  fixtures :pages, :users

  def setup
    # let's make some gallery
    # there are no galleries in fixtures yet.
    #
    @gallery = Gallery.create! :title => 'gimme pictures', :user => users(:blue)
    @asset = Asset.create_from_params({
      :uploaded_data => upload_data('photo.jpg')}) do |asset|
        asset.parent_page = @gallery
      end
    @gallery.add_image!(@asset, users(:blue))
    @asset.save!
  end

  def test_new
    login_as :blue
    get :new
    assert_response :success
  end

  def test_create_zip
    login_as :blue
    post :create, :page_id => @gallery.id, :file => upload_data('subdir.zip')
    assert_response :success  # or does this redirect to the edit page?
  end

  def test_create
    login_as :blue
    post :create, :page_id => @gallery.id, :file => upload_data('photo.jpg')
    assert_response :success # or does this redirect to the edit page?
  end

  def test_edit
    login_as :blue
    get :edit, :id => @asset.id
    assert_response :success
    assert assigns(:image).id == @asset.id
  end

  def test_update
    login_as :blue
    post :update, :id => @asset.id, :title => 'New Title'
    assert_response :success
    assert assigns(:image).title == 'New Title'

    post :update, :id => @asset.id, :cover => 1
    assert_response :success
  end

  def test_destroy
    login_as :blue
    assert_difference '@gallery.assets.count' do
      delete :destroy, :id => @asset.id
    end
  end

end
