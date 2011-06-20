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

# this controller does not really even exist yet:
  #azul: I think it does - at least there is some base page magic
  def test_create
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, :page_id => Gallery.param_id, :page => {:title => 'pictures'}, :assets => [upload_data('photo.jpg')]
    end

    assert_not_nil assigns(:page)
    assert_equal 1, assigns(:page).images.count
    assert_not_nil assigns(:page).page_terms
    assert_equal assigns(:page).page_terms, assigns(:page).images.first.page_terms
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
    login_as :blue
    post :update, :page_id => Gallery.find(:first).id, :title => 'New Gallery Title'
    assert_response :success
    assert assigns(:page).title == 'New Gallery Title'
    # what else do we update for the gallery?
  end

  def test_destroy
  end

end
