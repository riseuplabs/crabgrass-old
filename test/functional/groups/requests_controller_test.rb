require File.dirname(__FILE__) + '/../../test_helper'
require 'groups/requests_controller'

# Re-raise errors caught by the controller.
class Groups::RequestsController; def rescue_action(e) raise e end; end

class Groups::RequestsControllerTest < Test::Unit::TestCase
  fixtures :users, :memberships, :groups, :profiles, :federatings

  def setup
    @controller = Groups::RequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_cant_create_invite
    login_as :green
    assert_no_difference 'RequestToJoinUs.count' do
      post :create_invite, :id => groups(:fau).to_param, :recipients => ['red', 'blue']
      assert_permission_denied
    end
  end

  def test_create_invite
    login_as :gerrard

    assert_difference 'RequestToJoinUs.count', 3 do
      post :create_invite, :id => groups(:cnt).to_param, :recipients => ['yellow', 'purple', 'orange']
    end

#    login_as :yellow
#    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:yellow)})
#    get :reject, :id => request.id
#    assert_response :redirect

#    login_as :purple
#    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:purple)})
#    get :approve, :id => request.id
#    assert_response :redirect

#    login_as :gerrard
#    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:orange)})
#    get :destroy, :id => request.id
#    assert_response :redirect
  end

  def test_create_join
    login_as :green
    get :create_join, :id => groups(:animals).to_param
    assert_response :success
    assert_difference 'RequestToJoinYou.count', 1 do
      post :create_join, :group => groups(:animals), :send => "Send Request"
    end
  end

  def test_list_group
    login_as :blue
    get :list, :id => groups(:rainbow).to_param
    assert_response :success
  end

  def test_join_not_logged_in
    get :create_join, :id => groups(:rainbow).to_param
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def test_join_logged_in
    login_as :red

    assert_difference 'Request.count', 0, "no new membership requests should be accepted" do
      get :create_join, :id => groups(:private_group).to_param
      assert_permission_denied

      post :create_join, :id => groups(:private_group).to_param, :send => "Send Request"
      assert_permission_denied
    end

    groups(:public_group).profile.update_attribute(:may_request_membership, true)
    get :create_join, :id => groups(:public_group).to_param
    assert_response :success
    assert_difference 'Request.count', 1, "join request should create a request" do
      post :create_join, :id => groups(:public_group).to_param, :send => "Send Request"
      assert_response :success, "join public group with open membership."
    end
  end

end
