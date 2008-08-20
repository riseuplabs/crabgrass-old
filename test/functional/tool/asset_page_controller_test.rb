require File.dirname(__FILE__) + '/../../test_helper'
require 'asset_page_controller'

# Re-raise errors caught by the controller.
class AssetPageController; def rescue_action(e) raise e end; end

class Tool::AssetControllerTest < Test::Unit::TestCase
  fixtures :users, :groups
  @@private = Media::AssetStorage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = Media::AssetStorage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @controller = AssetPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
    Media::Process::Base.log_to_stdout_when = :on_error
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end

  def test_show
    asset = Asset.make :uploaded_data => upload_data('photo.jpg')
    page = create_page :data => asset

    @controller.stubs(:login_or_public_page_required).returns(true)
    post :show, :page_id => page.id, :id => 1
    assert_response :success
#    assert_template 'show'
    assert_equal asset.private_filename, assigns(:asset).private_filename, "should fetch the correct file"
  end
  
  def test_create
    login_as :gerrard

    get 'create'
#    assert_template 'create', "should render asset creation page"
    
#    post 'create'
#    assert_equal "You must select a file.", flash[:error], "shouldn't be able to create an asset page with no asset"

    assert_no_difference 'Asset.count' do
      post 'create', :asset => {:uploaded_data => ""}
      assert_equal "You must select a file.", flash[:error], "shouldn't be able to create an asset page with no asset"
    end
    
    assert_difference 'Thumbnail.count', 6, "image file should generate 6 thumbnails" do
      post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}
      assert_response :redirect
    end
    
  end

  def test_create_in_group
    login_as :blue

    get 'create'

    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}, :group_id => groups(:rainbow).id
    assert_equal 1, assigns(:page).groups.length, "asset page should belong to one group (no title)"
    assert_equal groups(:rainbow), assigns(:page).groups.first, "asset page should belong to rainbow group (no title)"

    post 'create', :page => {:title => "non-blank title", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}, :group_id => groups(:rainbow).id
    #assert_equal 1, assigns(:page).groups.length, "asset page should belong to one group (non-blank title)"
    assert_equal groups(:rainbow), assigns(:page).groups.first, "asset page should belong to rainbow group (non-blank title)"
  end


  def test_update
    login_as :gerrard
    get 'create'
    
    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}    
    assert_difference 'Asset::Version.count', 1, "jpg should version" do
      post 'update', :page_id => assigns(:page).id, :asset => {:uploaded_data => upload_data('photo.jpg')}
    end    
  end
  
  def test_destroy_version
    login_as :gerrard
    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}
    @asset = assigns(:asset)
    @version_filename = @asset.versions.find_by_version(1).private_filename
    post 'update', :page_id => assigns(:page).id, :asset => {:uploaded_data => upload_data('photo.jpg')}
    @page = assigns(:page)
    @asset = assigns(:asset)
    
    @controller.stubs(:login_or_public_page_required).returns(true)
    post :destroy_version, :controller => "asset_page", :page_id => @page.id, :id => 1
    assert_redirected_to @controller.page_url(@page)
    assert File.exists?(@asset.private_filename)
    assert !File.exists?(@version_filename)

    get :show, :page_id => @page.id
    assert_response :success
    assert_equal 1, assigns(:asset).versions.size
  end

  def test_destroy_version_2
    login_as :gerrard
    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}
    post 'update', :page_id => assigns(:page).id, :asset => {:uploaded_data => upload_data('photo.jpg')}
    assert_difference 'Asset::Version.count', -1, "destroy should remove a version" do
      post :destroy_version,  :page_id => assigns(:page).id, :id => 1
    end
  end

  def test_generate_preview
    login_as :gerrard

    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => upload_data('photo.jpg')}

    assert_difference 'Thumbnail.count', 0, "the first time an asset is shown, it should call generate preview" do
      xhr :post, 'generate_preview', :page_id => assigns(:page).id
    end
  end


  protected
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    AssetPage.create(defaults.merge(options))
  end
end
