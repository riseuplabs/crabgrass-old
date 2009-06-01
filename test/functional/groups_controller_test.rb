require File.dirname(__FILE__) + '/../test_helper'
require 'groups_controller'
#showlog
# Re-raise errors caught by the controller.
class GroupsController; def rescue_action(e) raise e end; end

class GroupsControllerTest < Test::Unit::TestCase
  fixtures :groups, :users, :memberships, :profiles, :pages, :sites,
            :group_participations, :user_participations, :tasks, :page_terms

  include UrlHelper

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Conf.disable_site_testing
  end

  def test_my
    login_as :gerrard
    get :my
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_directory
    login_as :gerrard
    get :directory
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_directory_letter
    login_as :blue
    get :directory, :letter => 'r'
    assert_response :success

    assert_equal 1, assigns(:groups).size
    assert_equal "rainbow", assigns(:groups)[0].name
  end

  def test_index
    login_as :gerrard
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_get_create
    login_as :gerrard
    get :create

    assert_response :success
    assert_select "form#createform"
  end

  def test_create_group
    login_as :gerrard
    assert_difference 'Group.count' do
      post :create, :group => {:name => 'test-create-group', :full_name => "Group for Testing Group Creation!", :summary => "None."}
      assert_response :redirect
      group = Group.find_by_name 'test-create-group'
      assert_redirected_to url_for_group(group, :action => 'show')
      assert_equal assigns(:group).name, 'test-create-group'
      assert_equal group.name, 'test-create-group'
    end
  end

#  def test_create_group_with_council
#    login_as :gerrard
#    assert_difference 'Group.count', 2 do
#      post :create, :group => {:name => 'group-with-council', :full_name => "Group for Testing Group Creationi with council!", :summary => "None."}, :add_council => "true"
#      assert_response :redirect
#      group = Group.find_by_name 'group-with-council'
#      assert_redirected_to url_for_group(group, :action => 'show')
#      assert_equal assigns(:group).name, 'group-with-council'
#      assert_equal group.name, 'group-with-council'
#      council = Group.find_by_name 'group-with-council+group-with-council_admin'
#      assert council.council?
#      assert_equal council.id, group.council.id
#    end
#  end

  def test_create_committee
    login_as :gerrard
    num_groups = Group.count
    num_committees = Committee.count
    # simulate user creating a committee:
    #    first a get request to get the page with the committee creation form
    get :create, :parent_id => groups(:true_levellers).id, :id => 'committee'
    assert_equal num_committees, Committee.count, "should not be an additional committee yet"
    #    then a post request to submit the committee creation form
    post :create, :parent_id => groups(:true_levellers).id, :group => {:name => 'committee', :full_name => "committee!", :summary => ""}, :id => 'committee'
    assert_equal num_committees + 1, Committee.count, "should be an additional committee now"
    assert_equal num_groups + 1, Group.count, "the new committee should also be counted as a new group"
  end

  def test_create_committee_when_not_member_of_group
    login_as :gerrard

    assert_difference 'Committee.count', 1, "should create a new committee" do
      post :create, :parent_id => groups(:true_levellers).id, :group => {:short_name => 'committee', :full_name => "committee!", :summary => ""}, :id => 'committee'
    end

    assert_no_difference 'Committee.count', "should not create a new committee, since gerrard is not in rainbow group" do
      post :create, :parent_id => groups(:rainbow).id, :group => {:short_name => 'committee', :full_name => "committee!", :summary => ""}, :id => 'committee'
    end
  end

  def test_create_fails_when_name_is_taken
    login_as :gerrard
    assert_difference 'Group.count', 1,  "should have created a new group" do
      post :create, :group => {:name => 'test-create-group'}
    end

    assert_no_difference 'Group.count', "should not create group with name of an existing group" do
      post :create, :group => {:name => 'test-create-group'}
    end

    assert_no_difference 'Group.count', "should not create group with name of an existing user" do
      post :create, :group => {:name => users(:gerrard).login}
    end
  end

end
