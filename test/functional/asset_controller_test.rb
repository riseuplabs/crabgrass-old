require File.dirname(__FILE__) + '/../test_helper'
require 'asset_controller'

# Re-raise errors caught by the controller.
class AssetController; def rescue_action(e) raise e end; end

class AssetControllerTest < Test::Unit::TestCase
  Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
  Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"

  def setup
    @controller = AssetController.new
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

    @controller.stubs(:public_or_login_required).returns(true)
    @controller.stubs(:is_public).returns(false)

    post :show, :id => asset.id, :filename => [asset.filename]
    assert_response :success, "should get asset"
    assert_equal asset.full_filename, assigns(:asset).full_filename, "should be expected asset"
#require 'ruby-debug'; debugger;
    post :show, :id => asset.id, :filename => [asset.filename], :version => 1
#    assert_response :success, "should get version 1 of asset"
    assert_equal asset.versions.first.full_filename, assigns(:asset).full_filename, "should be version 1 of asset"

    post :show, :id => asset.id, :filename => [asset.filename], :version => 2
    assert_response :not_found, "should not find anything for version 2 of asset"
  end
  
  def test_create
    # TODO: figure out what create action is supposed to do and then write this test
  end
  
  def test_destroy
    # TODO: figure out what destroy action is supposed to do and then write this test
  end

  protected
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    AssetPage.create(defaults.merge(options))
  end
end
