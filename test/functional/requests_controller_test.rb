require File.dirname(__FILE__) + '/../test_helper'
require 'requests_controller'

# Re-raise errors caught by the controller.
class RequestsController; def rescue_action(e) raise e end; end

class RequestsControllerTest < Test::Unit::TestCase
  fixtures :users, :memberships, :groups, :profiles, :federatings, :sites, :requests

  def setup
    @controller = RequestsController.new
    @request    = ActionController::TestRequest.new
    @request.host = Site.default.domain
    @response   = ActionController::TestResponse.new
  end

  def test_cant_create_invite
    login_as :green
    assert_no_difference 'RequestToJoinUs.count' do
      post :create_invite, :group_id => groups(:fau).id, :recipients => ['red', 'blue']
    end
  end

  def test_create_invite
    login_as :gerrard

    assert_difference 'RequestToJoinUs.count', 3 do
      post :create_invite, :group_id => groups(:cnt).id, :recipients => ['yellow', 'purple', 'orange']
    end

    login_as :yellow
    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:yellow)})
    get :reject, :request => request
    assert_response :redirect

    login_as :purple
    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:purple)})
    get :approve, :request => request
    assert_response :redirect

    login_as :gerrard
    request = RequestToJoinUs.find(:last, :conditions => {:recipient_id => users(:orange)})
    get :destroy, :request => request
    assert_response :redirect    
  end

  def test_create_join
    login_as :green
    get :create_join, :group_id => groups(:animals).id
    assert_response :success
    assert_difference 'RequestToJoinYou.count', 1 do
      post :create_join, :group_id => groups(:animals).id, :send => "Send Request"
    end
  end
    

  def test_list_group
    login_as :blue
    get :list, :group_id => 2
    assert_response :success
  end


  def test_join_not_logged_in
    get :create_join, :group_id => groups(:rainbow).id
#    assert_response :success
#    assert_template 'show_nothing'
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def test_join_logged_in
    login_as :red

    get :create_join, :group_id => groups(:private_group).id
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
#    assert_template 'show_nothing', "dolphin can't get join :private_group"

    post :create_join, :group_id => groups(:private_group).id, :send => "Send Request"
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
#    assert_template 'show_nothing', "dolphin can't post join :private_group"

    # Public Group does not accept new members...
    assert_difference 'Request.count', 0, "no new membership requests should be accepted" do
      get :create_join, :group_id => groups(:public_group).id
      assert_response :redirect
      assert_redirected_to :controller => :account, :action => :login
      post :create_join, :group_id => groups(:public_group).id, :send => "Send Request"
      assert_response :redirect
      assert_redirected_to :controller => :account, :action => :login
#    assert_template 'show_nothing', "now join public_group should return show_nothing"
    end


    groups(:public_group).accept_new_membership_requests = true
    groups(:public_group).save!
    get :create_join, :group_id => groups(:public_group).id
    assert_response :success
#    assert_template 'join'
    assert_difference 'Request.count', 1, "join request should create a request" do
      post :create_join, :group_id => groups(:public_group).id, :send => "Send Request"
      assert_response :success, "join public group with open membership."
    end

    groups(:public_group).accept_new_membership_requests = false
    groups(:public_group).save!

  end



  def test_join_as_member
    login_as :blue
    assert_difference 'Request.count', 0, "no new membership requests should be accepted" do
      get :create_join, :group_id => groups(:animals).id
#      assert_response :redirect, "Join Page should not be available to members."
#      assert_redirected_to :controller => :dispatch, :action => :dispatch
      post :create_join, :group_id => groups(:animals).id, :message => "Please let me join your progressive organization"
      assert_response :redirect, "No new join request should be created for members." 
      assert_redirected_to :controller => :dispatch, :action => :dispatch
    end
  end

end
