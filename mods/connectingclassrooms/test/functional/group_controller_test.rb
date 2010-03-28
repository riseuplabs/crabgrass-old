require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :sites, :federatings, :profiles

  include UrlHelper

  def setup
    # this site is listing on localhost but it is also the default
    # so it also works for tests as long as it is the only site loaded.
    enable_site_testing 'connectingclassrooms'
  end

  def teardown
    disable_site_testing
  end

  def test_group_creation_for_teacher
    login_as :teacher
    get :new
    assert_no_select 'blockquote', 'Sorry. You do not have the ability to perform that action.'
    assert_select 'h3', 'New group'
    assert_select "form#createform[action='/groups/create']"
    assert_response :success
    assert_difference 'Group.count' do
      post :create, :group => { :name => "test-teacher-group", :full_name => "Teacher creating group"}
      assert_response :redirect
      group = Group.find_by_name 'test-teacher-group'
      assert_redirected_to url_for_group(group, :action => 'edit')
    end
  end

  def test_no_group_creation_for_student
    login_as :student
    get :new
    assert_response :success
    assert_template 'common/permission_denied'
    assert_select 'blockquote', 'Sorry. You do not have the ability to perform that action.'
    assert_no_difference 'Group.count' do
      post :create, :name => "test-student-group", :display_name => "Student creating group"
      assert_response :success
      assert_template 'common/permission_denied'
    end
  end
end
