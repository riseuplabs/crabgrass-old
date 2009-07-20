require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/announcements_controller'

# Re-raise errors caught by the controller.
class Admin::AnnouncemetsController; def rescue_action(e) raise e end; end

class AnnouncementsControllerTest < Test::Unit::TestCase

  fixtures :users, :sites, :groups, :memberships, :pages

  def setup
    @controller = Admin::AnnouncementsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    enable_unlimited_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_index
    login_as :penguin
    get :index
    assert_response :success
    assert_not_nil pages=assigns(:pages), "announcement index should return pages"
    assert_equal AnnouncementPage.all.sort,pages.sort, "AnnouncmentsController#indes should list all announcements."
  end

  def test_no_admin
    login_as :red
    assert_no_access "only site admins may access the actions."
  end

  def test_no_site
    disable_site_testing
    login_as :penguin
    assert_no_access "none of the announcements actions should be enabled without sites."
  end

  def test_new
    login_as :penguin
    get :new
    assert_response :redirect
  end

  def test_edit
    login_as :penguin
    get :edit, :id => 210
    # penguin does not have access to this page.
    assert_response :missing
    get :edit, :id => 260
    assert_response :success
  end

  #  def test_create
  #  create happens as a AnnouncementPage creation.
  #  end

  #  def test_update
  #  end

  def test_destroy
    login_as :penguin
    assert_no_difference 'Page.count', "should not allow destruction of non-announcements" do
      get :destroy, :id => 210
      assert_redirected_to :controller => 'account', :action => 'login'
    end
    assert_difference 'Page.count', -1, "page count should lower as announcement is destroyed." do
      get :destroy, :id => 260
    end
  end

  def assert_no_access(message="")
    get :index
    assert_response :redirect, message
    get :new
    assert_response :redirect, message
    post :update
    assert_response :redirect, message
    get :destroy
    assert_response :redirect, message
  end
end
