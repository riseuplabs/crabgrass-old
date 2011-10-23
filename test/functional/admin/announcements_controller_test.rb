require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AnnouncementsControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships, :pages

  def setup
    enable_site_testing('unlimited')
  end

  def teardown
    disable_site_testing
  end

  def test_permissions_alias_may_admin_site
    @controller.expects(:may_admin_site?).returns(true)
    @controller.may_index_announcements?
  end

  def test_index
    user = users(:penguin)
    user.expects(:may?).with(:admin, Site.current).returns(true).at_least(1)
    login_as user
    get :index
    assert_response :success
    assert_not_nil pages=assigns(:pages), "announcement index should return pages"
    assert_equal AnnouncementPage.all.sort,pages.sort, "AnnouncmentsController#indes should list all announcements."
  end

  def test_new
    login_as :penguin
    get :new
    assert_permission_denied
  end

  def test_edit
    user = users(:penguin)
    user.expects(:may?).with(:admin, Site.current).returns(true).at_least(1)
    login_as user
    assert_raise ActiveRecord::RecordNotFound do
      # 210 is not an AnnouncementPage
      get :edit, :id => 210
    end
    # penguin does not have access to this page.
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
      assert_permission_denied
    end
    user = users(:penguin)
    user.expects(:may?).with(:admin, Site.current).returns(true).at_least(1)
    login_as user
    assert_difference 'Page.count', -1, "page count should lower as announcement is destroyed." do
      get :destroy, :id => 260
    end
  end

end
