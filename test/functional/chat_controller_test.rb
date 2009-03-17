require File.dirname(__FILE__) + '/../test_helper'
require 'chat_controller'

# Re-raise errors caught by the controller.
class ChatController; def rescue_action(e) raise e end; end

class ChatControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :memberships, :sites

  def setup
    @controller = ChatController.new
    @request    = ActionController::TestRequest.new
    @request.host = Site.default.domain
    @response   = ActionController::TestResponse.new
  end

  def test_index_when_not_logged_in
    get :index
    assert_response :redirect, "should require login to see chat index page"
  end
  
  def test_index_when_logged_in
    login_as :quentin
    get :index
    assert_response :success, "logged in user should get to chat index page"
#    assert_template 'index'
  end
  
  def test_channel_when_not_logged_in
    post :channel, :id => groups(:rainbow).name
    assert_response :redirect, "should require login to reach chat channel"
  end
  
  def test_channel_when_not_in_group
    login_as :quentin
    get :index # this makes @controller.current_user work right (?)

    post :channel, :id => groups(:rainbow).name
    assert_response :redirect, "should require group membership to reach chat channel"
  end
  
  def test_channel_when_in_group
    login_as :blue
    get :index # this makes @controller.current_user work right (?)

    post :channel, :id => groups(:rainbow).name
    assert_response :success, "should reach chat channel"
  end
end
