require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :sites

  def setup
    setup_site_with_admins
  end

  def test_non_siteadmin_may_not_create_group
    with_site 'site_with_admins' do
      login_as @non_admin
      get :new
      assert_template 'common/permission_denied'
      post :create, :name=>"test-group"
      assert_template 'common/permission_denied'
    end
  end

  def test_siteadmin_may_create_group
    with_site 'site_with_admins' do
      login_as @admin
      get :new
      assert_response :success
      assert_difference 'Group.count' do
       post :create, :group => {:name=>"test-group"}
      end
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => "test-group"
    end
  end

end
