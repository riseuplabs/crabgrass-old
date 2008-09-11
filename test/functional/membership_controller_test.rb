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
  end
  
  def test_list_when_logged_in
    login_as :red
    get :list, :id => groups(:rainbow).name
    assert_response :success, "list rainbow should succeed, because user red in group rainbow"

    groups(:public_group).publicly_visible_members = true
    groups(:public_group).save!
    get :list, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed, because membership is public"
    
    get :list, :id => groups(:private_group).name
    assert_response :success, "list private_group should succeed"

    groups(:public_group).publicly_visible_members = false
    groups(:public_group).save!

    get :list, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed"
  end

  def test_leave
    login_as :blue
    
    get :leave, :id => groups(:public_group).name
    assert_response :success
    
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

end
