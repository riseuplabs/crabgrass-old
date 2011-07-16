require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryControllerTest < ActionController::TestCase
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

  def test_show
    login_as :blue
    gallery = Gallery.create!( :user => users(:blue),
      :title => "Empty Gallery")
    get :show, :page_id => gallery.id
    assert_response :success
    assert_equal [], assigns['images']
  end


# this controller does not really even exist yet:
  #azul: I think it does - at least there is some base page magic
  def test_create
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, :id => Gallery.param_id, :page => {:title => 'pictures'}, :assets => [upload_data('photo.jpg')]
    end

    assert_not_nil assigns(:page)
    assert_equal 1, assigns(:page).images.count
    assert_not_nil assigns(:page).page_terms
    assert_equal assigns(:page).page_terms, assigns(:page).images.first.page_terms
  end
  
  def test_create_from_zip
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, :id => Gallery.param_id, :page => {:title => 'pictures 2'}, 
           :assets => [upload_data('photo.jpg'), upload_data('subdir.zip')]
    end
    
    assert_not_nil assigns(:page)
    assert_equal 2, assigns(:page).images.count
  end

  def test_show
    login_as :blue
    get :show, :page_id => @gallery.id
    assert_response :success
    assert_not_nil assigns(:images)
  end

  def test_edit
    login_as :blue
    get :edit, :page_id => @gallery.id
    assert_response :success
  end

  def test_update
    # we need two images
    @asset2 = Asset.create_from_params({
      :uploaded_data => upload_data('photo.jpg')}) do |asset|
        asset.parent_page = @gallery
      end
    @gallery.add_image!(@asset2, users(:blue))
    @asset2.save!
    login_as :blue
    post :update, :page_id => Gallery.find(:first).id,
      :sort_gallery => [@asset2.id, @asset.id]
    assert_response :redirect
    assert_equal [@asset2, @asset], @gallery.images
  end

  def test_update_cover
    login_as :blue
    post :update, :page_id => @gallery.id,
      :page => {:cover_id => @asset.id}
    assert_response :redirect
    assert_equal @asset, @gallery.reload.cover
  end


end
