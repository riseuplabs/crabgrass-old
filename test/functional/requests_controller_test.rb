require File.dirname(__FILE__) + '/../test_helper'
require 'membership_controller'

# Re-raise errors caught by the controller.
class RequestsController; def rescue_action(e) raise e end; end

class RequestsControllerTest < Test::Unit::TestCase
  fixtures :users, :memberships, :groups, :profiles

  def setup
    @controller = RequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

=begin
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
=end

end
