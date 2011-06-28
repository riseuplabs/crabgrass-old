require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryImageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :groups, :memberships

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
    get :new, @page_id => @gallery.id
    assert_response :success
  end

  def test_create_zip
    login_as :blue
    assert_difference '@gallery.assets.count' do
      post :create, :page_id => @gallery.id, :zipfile => upload_data('subdir.zip')
    end
  end

  def test_may_create
    @gallery.add(groups(:rainbow), :access => :edit)
    login_as :red
    assert_difference '@gallery.assets.count' do
      post :create, :page_id => @gallery.id, :assets => [upload_data('photo.jpg')]
    end
  end

  def test_may_not_create
    @gallery.add(groups(:rainbow), :access => :view)
    login_as :red
    assert_no_difference '@gallery.assets.count' do
      post :create, :page_id => @gallery.id, :assets => [upload_data('photo.jpg')]
    end
  end

  def test_may_not_edit
    @gallery.add(groups(:rainbow), :access => :view)
    login_as :red
    xhr :get, :edit, :id => @asset.id, :page_id => @gallery.id
    assert_response :redirect
  end

  def test_may_edit
    @gallery.add(groups(:rainbow), :access => :edit)
    login_as :red
    xhr :get, :edit, :id => @asset.id, :page_id => @gallery.id
    assert_response :success
    assert_equal assigns(:image).id, @asset.id
    assert assigns(:image).caption.blank?
  end

  def test_may_not_update_caption
    @gallery.add(groups(:rainbow), :access => :view)
    @gallery.reload
    login_as :red
    post :update, :page_id => @gallery.id, :id => @asset.id,
      :caption => 'New Title'
    assert_response :redirect
    assert @asset.reload.caption.blank?
  end

  def test_may_update_caption
    @gallery.add(groups(:rainbow), :access => :edit)
    @gallery.reload
    login_as :red
    post :update, :page_id => @gallery.id, :id => @asset.id,
      :caption => 'New Title'
    assert_response :success
    assert_equal 'New Title',  @asset.reload.caption
  end

  def test_update_cover
    post :update, :page_id => @gallery.id, :id => @asset.id,
      :cover => 1
    assert_response :redirect
    assert @asset.reload.cover
  end

  def test_destroy
    login_as :blue
    assert_difference '@gallery.assets.count', -1 do
      delete :destroy, :id => @asset.id, :page_id => @gallery.id
    end
  end

  def test_show
    login_as :blue
    image = @gallery.assets.first
    xhr :get, :show, :id => @asset.id, :page_id => @gallery.id
    assert_response :success
    assert assigns(:showing)
  end

  def test_may_not_show
    login_as :red
    xhr :get, :show, :id => @asset.id, :page_id => @gallery.id
    assert_response :redirect
  end

  def test_may_show
    @gallery.add(groups(:rainbow), :access => :view)
    login_as :red
    xhr :get, :show, :id => @asset.id, :page_id => @gallery.id
    assert_response :success
    assert assigns(:showing)
  end


end
