require File.dirname(__FILE__) + '/../test_helper'
require 'assets_controller'

# Re-raise errors caught by the controller.
class AssetsController; def rescue_action(e) raise e end; end

class AssetsControllerTest < ActionController::TestCase
  fixtures :users, :pages, :user_participations, :assets, :sites

  @@private = AssetExtension::Storage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = AssetExtension::Storage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @controller = AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
    Media::Process::Base.log_to_stdout_when = :on_error

    Page.find(1).add users(:blue), :access => :admin
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end

  def test_show
    login_as :blue

    @asset = Asset.create :uploaded_data => upload_data('photo.jpg')
    @page = create_page :data => @asset
    @page.add( users(:blue), :access => :admin )
    @asset.uploaded_data = upload_data('image.png')
    @asset.save

    @controller.stubs(:public_or_login_required).returns(true)
    @controller.stubs(:is_public).returns(false)

    post :show, :id => @asset.id, :filename => [@asset.filename]
    assert_response :success, "should get asset"
    assert_equal @asset.private_filename, assigns(:asset).private_filename, "should be expected asset"

    post :show, :id => @asset.id, :filename => [@asset.filename], :version => 1
    assert_response :success, "should get version 1 of asset"
    assert_equal @asset.versions.earliest.private_filename, assigns(:asset).private_filename, "should be version 1 of asset"

    post :show, :id => @asset.id, :filename => [@asset.filename], :version => 2
    assert_response :success, "should get version 1 of asset"
    assert_equal @asset.versions.latest.private_filename, assigns(:asset).private_filename, "should be version 2 of asset"

    post :show, :id => @asset.id, :filename => [@asset.filename], :version => 3
    assert_response :not_found, "should not find anything for version 2 of asset"

    @asset_no_page = Asset.create :uploaded_data => upload_data('bee.jpg')
    @asset_no_page.save
    post :show, :id => @asset_no_page.id
    assert_response :redirect
  end

  def test_create
    login_as :blue

    assert_difference 'Page.find(1).assets.length' do
      post 'create', :asset => {:uploaded_data => upload_data('photo.jpg'), :page_id => 1}
    end

    assert_difference 'Page.find(1).assets.length' do
      post 'create', :asset => {:uploaded_data => upload_data('photo.jpg'), :page_id => 1}
    end
  end

  def test_permissions
    User.current = nil # required, otherwise, create_page will add current user.

    @user = users(:blue)
    @page = create_page :title => 'test-access'
    assert !@user.may?(:edit, @page), 'user should not have write access to the page'

    login_as :blue

    assert_permission_denied do
      assert_no_difference 'Asset.count' do
        post 'create', :asset => {:uploaded_data => upload_data('photo.jpg'), :page_id => @page.id}
      end
    end

    @page.add(@user, :access => :edit)
    @page.save
    assert @user.may?(:edit, @page), 'user should have write access to the page'

    assert_difference('Page.find(%i).assets.length' % @page.id) do
      post 'create', :asset => {:uploaded_data => upload_data('photo.jpg'), :page_id => @page.id}
    end
  end

  def test_destroy(format="text/javascript")
    login_as :blue

    assert_difference 'Page.find(1).assets.length' do
      post 'create', :asset => {:uploaded_data => upload_data('photo.jpg'), :page_id => 1}
    end

    @request.accept = format 
    assert_difference 'Page.find(1).assets.length', -1 do
      post 'destroy', :id => assigns(:asset).id
      if format == "text/javascript"
        assert_response :success
      else
        assert_response :redirect
      end
    end
  end

  def test_destroy_html
     test_destroy("text/html")    
  end

  protected

  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    AssetPage.create(defaults.merge(options))
  end
end
