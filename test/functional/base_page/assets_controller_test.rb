require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/assets_controller'

# Re-raise errors caught by the controller.
class BasePage::AssetsController; def rescue_action(e) raise e end; end

class BasePage::AssetsControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags

  @@private = AssetExtension::Storage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = AssetExtension::Storage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @controller = BasePage::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end


  def test_show_popup
    login_as :blue
    get :show, :page_id => 1, :popup => true
    assert_response :success
  end

  def test_create_and_destroy
    login_as :blue

    assert_difference 'Page.find(1).assets.length' do
      post :create, :page_id => 1, :asset => {:uploaded_data => upload_data('photo.jpg')}
    end

    assert_difference 'Page.find(1).assets.length', -1 do
      post :destroy, :page_id => 1, :id => Page.find(1).assets.first.id
    end
  end
end
