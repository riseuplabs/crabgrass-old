require File.dirname(__FILE__) + '/../../test_helper'

class Groups::MembershipsControllerTest < ActionController::TestCase
  fixtures :users, :memberships, :groups, :profiles, :sites

  def setup
  end

  def test_list_when_not_logged_in
    get :list, :id => groups(:public_group).name
    assert_response :redirect, "login required to list membership of a group"
  end

  def test_list_when_logged_in
    login_as :red
    get :list, :id => groups(:rainbow).name
    assert_response :success, "list rainbow should succeed, because user red in group rainbow"

    groups(:public_group).profiles.public.may_see_members = true
    groups(:public_group).save!
    get :list, :id => groups(:public_group).name
    assert_response :success, "list public_group should succeed, because membership is public"

    get :list, :id => groups(:private_group).name
    assert_response :success, "list private_group should succeed"

    groups(:public_group).profiles.public.may_see_members = false
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

    assert users(:blue).direct_member_of?(groups(:cold))
    assert users(:green).direct_member_of?(groups(:cold))

    post :update, :id => groups(:cold).name, :group => {:user_ids => [users(:red).id.to_s]}, :commit => "Save"

    assert users(:red).direct_member_of?(groups(:warm)), "red should be in committee"
  end

  def test_edit
    login_as :blue
    get :edit, :id => groups(:warm).name
    assert_response :success
  end

  def test_remove_user_as_admin
    login_as :blue
    council = Council.new :name => "committee", :parent => groups(:animals)
    groups(:animals).add_committee!(council)

    assert_difference "Membership.count", -1 do
      post :destroy, :id => groups(:animals).name, :user_id => users(:penguin).id
    end
    assert_response :success
  end

  def test_may_not_remove_admin_as_admin
    login_as :blue
    User.current = users(:blue)
    council = Council.new :name => "committee", :parent => groups(:animals)
    groups(:animals).add_committee!(council)

    council.add_user! users(:penguin)
    assert_no_difference "Membership.count" do
      post :destroy, :id => groups(:animals).name, :user_id => users(:penguin).id
    end
    assert_permission_denied
  end

  def test_may_not_remove_user_as_user
    login_as :blue
    assert_no_difference "Membership.count" do
      post :destroy, :id => groups(:animals).name, :user_id => users(:penguin).id
    end
    assert_permission_denied
  end

end
