require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/asset_controller'

# Re-raise errors caught by the controller.
class Tool::AssetController; def rescue_action(e) raise e end; end

class Tool::AssetControllerTest < Test::Unit::TestCase
  Asset.file_storage = "#{RAILS_ROOT}/tmp/assets"
  Asset.public_storage = "#{RAILS_ROOT}/tmp/public/assets"

  def setup
    @controller = Tool::AssetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(Asset.file_storage)
    FileUtils.mkdir_p(Asset.public_storage)
  end

  def teardown
    FileUtils.rm_rf(Asset.file_storage)
    FileUtils.rm_rf(File.dirname(Asset.public_storage))
  end

  def test_destroy_version
    User.current = nil
    asset = Asset.create :uploaded_data => fixture_file_upload(File.join('files','image.png'), 'image/png')
    page = create_page :data => asset
    page.data.uploaded_data = fixture_file_upload(File.join('files','photos.png'), 'image/png')
    page.data.save
    assert File.exists?(page.data.full_filename)
    assert File.exists?(version_filename = page.data.find_version(1).full_filename)
    
    @controller.stubs(:login_or_public_page_required).returns(true)
    post :destroy_version, :controller => "tool/asset", :page_id => page.id, :id => 1
    assert_redirected_to @controller.page_url(page)
    assert File.exists?(page.data.full_filename)
    assert !File.exists?(version_filename)

    Tool::Asset.any_instance.stubs(:created_by).returns(stub(:both_names => 'a user'))
    get :show, :page_id => page.id
    assert_response :success
    assert_equal assigns(:page).data.versions.size, 1
  end

  protected
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    Tool::Asset.create(defaults.merge(options))
  end
end
