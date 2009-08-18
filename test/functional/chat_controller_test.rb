require File.dirname(__FILE__) + '/../test_helper'
require 'chat_controller'

# Re-raise errors caught by the controller.
class ChatController; def rescue_action(e) raise e end; end

class ChatControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :memberships, :sites

  def setup
    @controller = ChatController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index_when_not_logged_in
    get :index
    assert_login_required
  end

  def test_index_when_logged_in
    login_as :quentin
    get :index
    assert_response :success, "logged in user should get to chat index page"
  end

  def test_channel_when_not_logged_in
    post :channel, :id => groups(:rainbow).name
    assert_login_required
  end

  def test_channel_when_not_in_group
    login_as :quentin
    get :index # this makes @controller.current_user work right (?)

    post :channel, :id => groups(:rainbow).name
    assert_permission_denied
  end

  def test_channel_when_in_group
    login_as :blue
    get :index # this makes @controller.current_user work right (?)

    post :channel, :id => groups(:rainbow).name
    assert_response :success, "should reach chat channel"
  end

  def test_channel_archive_when_not_logged_in
    get :archive, :id => groups(:rainbow).name
    assert_login_required
  end

  def test_channel_archive_when_not_in_group
    login_as :quentin
    get :archive, :id => groups(:rainbow).name
    assert_permission_denied
  end

  def test_channel_archive_when_in_group
    login_as :blue
    get :archive, :id => groups(:rainbow).name
    assert_response :success, "should reach chat archive"
  end

end
