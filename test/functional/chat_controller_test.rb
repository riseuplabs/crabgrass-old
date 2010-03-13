require File.dirname(__FILE__) + '/../test_helper'

class ChatControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :sites

  def test_index_when_not_logged_in
    assert_login_required do
      get :index
    end
  end

  def test_index_when_logged_in
    login_as :quentin
    get :index
    assert_response :success, "logged in user should get to chat index page"
    assert assigns(:user).nil?, 'index action should not assign @user'
    assert assigns(:channel).nil?, 'index action should not assign @channel'
    assert assigns(:channel_user).nil?, 'index action should not assign @channel_user'
  end

  def test_channel_when_not_logged_in
    assert_login_required do
      get :channel, :id => groups(:rainbow).name
    end
  end

  def test_channel_when_not_in_group
    login_as :quentin
    assert_permission_denied do
      get :channel, :id => groups(:rainbow).name
    end
  end

  def test_channel_when_in_group
    login_as :blue
    get :channel, :id => groups(:rainbow).name
    assert_response :success, "should reach chat channel"
    assert_select 'a#chat', false, "Should not show link to join chat in chat."
 end

  def test_channel_archive_when_not_logged_in
    assert_login_required do
      get :archive, :id => groups(:rainbow).name
    end
  end

  def test_channel_archive_when_not_in_group
    login_as :quentin
    assert_permission_denied do
      get :archive, :id => groups(:rainbow).name
    end
  end

  def test_channel_archive_when_in_group
    login_as :blue
    get :archive, :id => groups(:rainbow).name
    assert_response :success, "should reach chat archive"
    assert assigns(:channel_user).nil?, 'archive action should not assign @channel_user'
  end


  def test_user_list_when_in_channel
    login_as :blue
    post :user_list, :id => groups(:rainbow).name
    assert_select 'div', :id => "c_user-#{users(:blue).id}"
  end

end
