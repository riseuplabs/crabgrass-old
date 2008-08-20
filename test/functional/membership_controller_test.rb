require File.dirname(__FILE__) + '/../test_helper'
require 'membership_controller'

# Re-raise errors caught by the controller.
class MembershipController; def rescue_action(e) raise e end; end

class MembershipControllerTest < Test::Unit::TestCase
  fixtures :users, :memberships, :groups, :profiles

  def setup
    @controller = MembershipController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_list_when_not_logged_in
    get :list, :id => groups(:public_group).name
    assert_response :redirect, "login required to list membership of a group"
#    assert_redirected_to :login, "redirect to login page"
  end
  
  def test_list_when_logged_in
    login_as :red
    get :list, :id => groups(:rainbow).name
    assert_response :success, "list rainbow should succeed, because user red in group rainbow"
#    assert_template 'list', "list rainbow should return list template when logged in"

    groups(:public_group).publicly_visible_members = true
    groups(:public_group).save!
    get :list, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed, because membership is public"
#    assert_template 'list', "list public_group should return list template"
    
    get :list, :id => groups(:private_group).name
    assert_response :success, "list private_group should succeed"
#    assert_template 'show_nothing', "list private_group should return show_nothing"

    groups(:public_group).publicly_visible_members = false
    groups(:public_group).save!

    get :list, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed"
#    assert_template 'show_nothing', "now list public_group should return show_nothing"
  end

  def test_join_not_logged_in
    get :join, :id => groups(:rainbow).name
#    assert_response :success
#    assert_template 'show_nothing'
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def test_join_logged_in
    login_as :red

    get :join, :id => groups(:private_group).name
    assert_response :success
#    assert_template 'show_nothing', "dolphin can't get join :private_group"

    post :join, :id => groups(:private_group).name, :message => "Please let me join your progressive organization"
    assert_response :success
#    assert_template 'show_nothing', "dolphin can't post join :private_group"

    groups(:public_group).accept_new_membership_requests = true
    groups(:public_group).save!
    get :join, :id => groups(:public_group).name
    assert_response :success
#    assert_template 'join'

    assert_difference 'Page.count', 2, "join request should create 2 pages" do
      post :join, :id => groups(:public_group).name, :message => "Please let me join your progressive organization"
      assert_response :redirect
      assert_redirected_to :controller => 'me/requests'
    end

    groups(:public_group).accept_new_membership_requests = false
    groups(:public_group).save!

    get :join, :id => groups(:public_group).name
    assert_response :success, "join public_group should succeed"
#    assert_template 'show_nothing', "now join public_group should return show_nothing"

    # TODO:
    # add test for joining a group you are already a member of
    # add tests for joining groups with different levels of privacy
  end

  def test_leave
    login_as :blue
    
    get :leave, :id => groups(:public_group).name
    assert_response :success
#    assert_template 'leave'
    
    post :leave, :id => groups(:public_group).name
    assert_response :redirect
    assert_redirected_to @controller.url_for_group(groups(:public_group))
    assert_nil users(:blue).groups.find_by_name(groups(:public_group).name), "blue should not be a member of public group anymore"
    # TODO:
    # tests for leaving a group you are not a member of
    # tests for leaving a group when you are not logged in
  end

  def test_update
    # TODO:
    # test for updating groups (should raise error or something)
    # test for updating committee when not logged in
    # test for updating committee when not a member
    # More Major TODO: This action doesn't function the way I think it should -af
    
    login_as :red
    
    get :update, :id => groups(:warm).name
    assert_response :redirect
    assert_redirected_to :action => 'list', :id => groups(:warm).name

    assert users(:blue).direct_member_of?(groups(:warm))
    assert users(:quentin).direct_member_of?(groups(:warm))
#    assert !users(:red).direct_member_of?(groups(:warm)), "red should not be in committee"

    post :update, :id => groups(:warm).name, :group => {:user_ids => [users(:red).id.to_s]}, :commit => "Save"

    assert users(:red).direct_member_of?(groups(:warm)), "red should be in committee"
  end

  def test_invite
    # TODO:
    # tests for invites for a group you are not a member of
    # tests for invites when you are not logged in
    
    login_as :red
    
    get :invite, :id => groups(:rainbow).name
    assert_response :success
#    assert_template 'invite'
    assert true
    
    assert_difference 'Page.count', 4, "should generate 2 invite/discussion pairs (4 pages total)" do
      post :invite, :id => groups(:rainbow).name, :message => "You are invited!", :commit => "Send invites", :users => "dolphin penguin bad_login"
    end
    # TODO: test flash message behavior
  end

  def test_requests
    # TODO:
    # tests requests for a group you are not a member of
    # tests requests when you are not logged in
    login_as :blue
    get :requests, :id => groups(:rainbow).name
    assert_response :success
#    assert_template 'requests'

  end
end
