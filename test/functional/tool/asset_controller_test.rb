require File.dirname(__FILE__) + '/../../test_helper'
require 'asset_page_controller'

# Re-raise errors caught by the controller.
class AssetPageController; def rescue_action(e) raise e end; end

class Tool::AssetControllerTest < Test::Unit::TestCase
  fixtures :users, :groups
  Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
  Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"

  def setup
    @controller = AssetPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
  end

  def teardown
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(File.dirname(Asset.public_storage))
  end

  def test_show
    asset = Asset.create :uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')
    page = create_page :data => asset
    page.data.uploaded_data = fixture_file_upload(File.join('files','photos.png'), 'image/png')
    page.data.save
    assert File.exists?(page.data.full_filename)
    assert File.exists?(version_filename = page.data.versions.find_by_version(1).full_filename)

    @controller.stubs(:login_or_public_page_required).returns(true)
    post :show, :page_id => page.id, :id => 1
    assert_response :success
    assert_template 'show'
    assert_equal asset.full_filename, assigns(:asset).full_filename, "should fetch the correct file"
  end
  
  def test_create
    login_as :gerrard

    get 'create'
    assert_template 'create', "should render asset creation page"
    
#    post 'create'
#    assert_equal "You must select a file.", flash[:error], "shouldn't be able to create an asset page with no asset"

    assert_no_difference 'Asset.count' do
      post 'create', :asset => {:uploaded_data => ""}
      assert_equal "You must select a file.", flash[:error], "shouldn't be able to create an asset page with no asset"
    end
    
    assert_difference 'Asset.count', 3, "image file should generate 2 thumbnails" do
      post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')}
      assert_response :redirect
    end
    
    assert_difference 'Asset.count', 1, "doc file should not generate thumbnails immediately" do
      post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','msword.doc'), 'application/msword')}
      assert_response :redirect
    end

    assert_difference 'Asset.count', 1, "raw file should not generate thumbnails" do
      post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','raw_file.bin'), 'default')}
      assert_response :redirect
    end
    
  end

  def test_create_in_group
    login_as :blue

    get 'create'

    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')}, :group_id => groups(:rainbow).id
    assert_equal 1, assigns(:page).groups.length, "asset page should belong to one group (no title)"
    assert_equal groups(:rainbow), assigns(:page).groups.first, "asset page should belong to rainbow group (no title)"

    post 'create', :page => {:title => "non-blank title", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')}, :group_id => groups(:rainbow).id
#require 'ruby-debug'; debugger;
    assert_equal 1, assigns(:page).groups.length, "asset page should belong to one group (non-blank title)"
    assert_equal groups(:rainbow), assigns(:page).groups.first, "asset page should belong to rainbow group (non-blank title)"
  end
    


  def test_update
    login_as :gerrard
    get 'create'
    
    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','gears.jpg'), 'image/jpg')}    
    assert_difference 'Asset.count', 1, "jpg should version" do
      post 'update', :page_id => assigns(:page).id, :asset => fixture_file_upload(File.join('files','gears2.jpg'), 'image/jpg')
    end
    
    post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','msword.doc'), 'application/msword')}    
    assert_difference 'Asset.count', 1, "doc should version" do
      post 'update', :page_id => assigns(:page).id, :asset => fixture_file_upload(File.join('files','msword2.doc'), 'application/msword')
    end
    
  end
  
  def test_destroy_version
    User.current = nil
    asset = Asset.create :uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')
    page = create_page :data => asset
    page.data.uploaded_data = fixture_file_upload(File.join('files','photos.png'), 'image/png')
    page.data.save
    assert File.exists?(page.data.full_filename)
    assert File.exists?(version_filename = page.data.versions.find_by_version(1).full_filename)
    
    @controller.stubs(:login_or_public_page_required).returns(true)
    post :destroy_version, :controller => "asset_page", :page_id => page.id, :id => 1
    assert_redirected_to @controller.page_url(page)
    assert File.exists?(page.data.full_filename)
    assert !File.exists?(version_filename)

    # i don't understand why this line fails:
    # AssetPage.any_instance.stubs(:created_by).returns(stub(:both_names => 'a user'))
    get :show, :page_id => page.id
    assert_response :success
    assert_equal assigns(:page).data.versions.size, 1
  end

  def test_destroy_version_2
    login_as :gerrard
    get 'create'
    post 'create', :page => {:title => "", :summary => ""},
         :asset => {:uploaded_data => fixture_file_upload(File.join('files','gears.jpg'), 'image/jpg')}    
    post 'update', :page_id => assigns(:page).id,
         :asset => fixture_file_upload(File.join('files','gears2.jpg'), 'image/jpg')
    assert_difference 'Asset.count', -1, "destroy should remove a version" do
      post :destroy_version,  :page_id => assigns(:page).id, :id => 1
    end
  end

  def test_generate_preview
    login_as :gerrard

    get 'create'

    assert_difference 'Asset.count', 1, "pdf file should not generate thumbnails immediately" do
      post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','test.pdf'), 'application/pdf')}
      assert_response :redirect
    end
    assert_difference 'Asset.count', 2, "eventually doc file should generate 2 thumbnails" do
      xhr :post, 'generate_preview', :page_id => assigns(:page).id
    end


    assert_difference 'Asset.count', 1, "doc file should not generate thumbnails immediately" do
      post 'create', :page => {:title => "", :summary => ""}, :asset => {:uploaded_data => fixture_file_upload(File.join('files','msword.doc'), 'application/msword')}
      assert_response :redirect
    end
    assert_difference 'Asset.count', 2, "eventually doc file should generate 2 thumbnails" do
      xhr :post, 'generate_preview', :page_id => assigns(:page).id
    end
  end


  protected
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    AssetPage.create(defaults.merge(options))
  end
end
