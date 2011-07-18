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
    @gallery.save!
    @asset.save!
  end

  def test_new
    login_as :blue
    get :new, :page_id => @gallery.id
    assert_response :success
  end

  def test_new_ready_for_progress_bar
    login_as :blue
    get :new, :page_id => @gallery.id
    assert_response :success
    assert_not_nil assigns['upload_id'],
      "new action should create upload-id"
    assert_select '#progress[style="display: none;"]', 1,
      "a hidden progress bar should be displayed" do
      assert_select '#bar[style="width: 10%;"]', "0 %",
        "the progress bar should contain a bar"
      end
    upload_id = assigns['upload_id']
    assert_select 'form[action*="X-Progress-ID"]' do
      assert_select 'input[type="hidden"][value="' + upload_id + '"]'
    end
  end

  def test_create_zip
    login_as :blue
    assert_difference '@gallery.assets.count' do
      post :create, :page_id => @gallery.id,
       :assets => [upload_data('subdir.zip')]
    end
    assert_equal Mime::JPG, Asset.last.content_type
    assert_equal @gallery.id, Asset.last.page_id
    assert_equal "fox", Asset.last.basename
  end

  def test_may_create
    @gallery.add(groups(:rainbow), :access => :edit).save!
    @gallery.save!
    login_as :red
    assert_difference '@gallery.assets.count' do
      post :create, :page_id => @gallery.id, :assets => [upload_data('photo.jpg')]
    end
    assert_equal @gallery.id, Asset.last.page_id
  end

  def test_may_not_create
    @gallery.add(groups(:rainbow), :access => :view).save!
    @gallery.save!
    login_as :red
    assert_no_difference '@gallery.assets.count' do
      post :create, :page_id => @gallery.id, :assets => [upload_data('photo.jpg')]
      assert_permission_denied
    end
  end

  def test_may_not_edit
    @gallery.add(groups(:rainbow), :access => :view).save!
    @gallery.save!
    login_as :red
    xhr :get, :edit, :id => @asset.id, :page_id => @gallery.id
    assert_permission_denied
  end

  def test_may_edit
    @gallery.add(groups(:rainbow), :access => :edit).save!
    @gallery.save!
    login_as :red
    xhr :get, :edit, :id => @asset.id, :page_id => @gallery.id
    assert_response :success
    assert assigns(:image)
    assert_equal assigns(:image).id, @asset.id
    assert assigns(:image).caption.blank?
  end

  def test_may_not_update_caption
    @gallery.add(groups(:rainbow), :access => :view).save!
    @gallery.save!
    login_as :red
    post :update, :page_id => @gallery.id, :id => @asset.id,
      :caption => 'New Title'
    assert_permission_denied
    assert @asset.reload.caption.blank?
  end

  def test_may_update_caption
    @gallery.add(groups(:rainbow), :access => :edit).save!
    @gallery.save!
    login_as :red
    post :update, :page_id => @gallery.id, :id => @asset.id,
      :image => {:caption => 'New Title' }
    assert_response :redirect
    assert_equal 'New Title',  @asset.reload.caption
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
    assert_permission_denied
  end

  def test_may_show
    @gallery.add(groups(:rainbow), :access => :view).save!
    @gallery.save!
    login_as :red
    xhr :get, :show, :id => @asset.id, :page_id => @gallery.id
    assert_response :success
    assert assigns(:showing)
  end

  def test_may_upload
    login_as :blue
    xhr :put, :update, :id => @asset.id, :page_id => @gallery.id,
        :assets => [upload_data('photo.jpg')]
    assert_response :success
  end

  def test_can_change_file_type
    login_as :blue
    xhr :put, :update, :id => @asset.id, :page_id => @gallery.id,
        :assets => [upload_data('cc.gif')]
    assert_response :success
  end

end
