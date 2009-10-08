require File.dirname(__FILE__) + '/../../test_helper'

class Groups::DirectoryControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :sites

  def test_non_siteadmin_may_not_create_group
    with_site :unlimited do
      login_as :gerrard
      get :my
      assert_response :success
      assert_select "h1", "Directory of Groups", "Gerrard should be able to see the group directory"
      assert_select "a[href=/groups/new]", false, "Gerrard should not see the create group link in group directory."
    end
  end

  def test_siteadmin_may_create_group
    with_site :unlimited do
      login_as :penguin
      get :my
      assert_response :success
      assert_select "a[href=/groups/new]", nil, "Penguin should see create group link in directory."
    end
  end

end
