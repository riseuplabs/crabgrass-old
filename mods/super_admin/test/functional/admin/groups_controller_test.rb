require File.dirname(__FILE__) + '/../test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships
  tests Admin::GroupsController
  
  def setup
    # @controller = UsersController.new
    # @request = ActionController::TestRequest.new
    # @response = ActionController::TestResponse.new
  end
  
  def test_index
    login_as :blue
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end
  
  def test_show
    login_as :blue
    @group = groups(:rainbow)
    get :show, :group_id => @group.id
    assert_response :success
    assert_equal @group.name, assigns(:group).name
  end
  
  def test_new
    login_as :blue
    get :new
    assert_response :success
    assert assigns(:group)
  end
  
  def test_create
    login_as :blue
    post :create, :group => {:name => 'testgroup', :link_name => 'TestGroup' }
    assert_redirected :action => 'show'
    assert_equal assigns(:group).login, 'testgroup'
    # todo: assert failing create test
  end
  
  def test_edit
    login_as :blue
    @group = groups(:rainbow)
    get :edit, :group_id => @group.id
    assert_response :success
    assert_equal @user.name, assigns(:group).name
  end
  
  def test_update
    login_as :blue
    @group = groups(:rainbow)
    # test change password and display name
    post :update, :group => {:name => 'Regenbogen (de)', :link_name => @group.link_name}
    assert_redirected :action => 'show'
    assert_equal assigns(:group).name, 'Regenbogen (de)'
  end
  
  def test_destroy
    login_as :blue
    @group = groups(:rainbow)
    get :destroy, :id => @group.name
    assert_redirected :action => 'index'
    assert_nil Group.find_by_name(@group.name)
  end
end
