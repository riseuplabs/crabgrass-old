require File.dirname(__FILE__) + '/../test_helper'
require 'groups_controller'

# Re-raise errors caught by the controller.
class GroupsController; def rescue_action(e) raise e end; end

class GroupsControllerTest < Test::Unit::TestCase
  fixtures :groups, :users, :memberships

  include UrlHelper

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    login_as :gerrard
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    login_as :gerrard
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:groups)
  end

  def test_show
    login_as :blue
    get :show, :id => groups(:rainbow).name

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
  end

  def test_show_when_not_logged_in
    get :show, :id => groups(:public_group).name    
    assert_response :success
    assert_template 'show'
    
    get :show, :id => groups(:private_group).name
    assert_response :not_found
    assert_template 'not_found'
#    assert_template 'dispatch/not_found'
  end

  def test_get_create
    login_as :gerrard
    get :create

    assert_response :success
    assert_template 'create'
    assert_select "form#createform"
  end

  def test_create
    login_as :gerrard
    num_groups = Group.count

    post :create, :group => {:name => 'test-create-group'}

    assert_response :redirect
    group = Group.find_by_name 'test-create-group'
    assert_redirected_to url_for_group(group, :action => 'show')
    assert_equal assigns(:group).name, 'test-create-group'
    assert_equal group.name, 'test-create-group'
    assert_equal num_groups + 1, Group.count
  end

  def test_create_fails_when_name_is_taken
    login_as :gerrard

    num_groups = Group.count
    post :create, :group => {:name => 'test-create-group'}
    assert_equal num_groups + 1, Group.count, "should have created a new group"

    num_groups = Group.count
    post :create, :group => {:name => 'test-create-group'}
    assert_equal num_groups, Group.count,
                 "should not create group with name of an existing group"

    post :create, :group => {:name => User.find(1).login}
    assert_equal num_groups, Group.count,
                 "should not create group with name of an existing user"
  end

  def test_edit
    login_as :blue
    get :edit, :id => groups(:rainbow).name

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
  end

  def test_update
    login_as :blue
    post :update, :id => groups(:rainbow).name
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => groups(:rainbow).name
  end

  def test_destroy
    login_as :gerrard
    num_groups = Group.count

    post :create, :group => {:name => 'short-lived-group'}

    group = Group.find_by_name 'short-lived-group'    
    assert_redirected_to url_for_group(group, :action => 'show')
    assert_equal num_groups + 1, Group.count

    post :destroy, :id => group.name
    assert_equal num_groups, Group.count
    assert_redirected_to :action => 'list'    
  end

  def test_login_required
    [:create, :edit, :destroy, :update].each do |action|
      assert_requires_login do |c|
        c.get action, :id => groups(:public_group).name
      end
    end

# should we test unlogged in stuff on a private group?
#    [:create, :edit, :destroy, :update].each do |action|
#      get :, :id => groups(:private_group).name
#      assert_template 'not_found'
#    end
  end

  def test_invite
    login_as :gerrard
    post :create, :group => {:name => 'awesome-new-group'}
    
    group = Group.find_by_name 'awesome-new-group'
    num_members = group.memberships.count
    assert_equal num_members, 1
    
# i'm not sure how to write tests  --af
#    post :invite, :user => 'blue'
  end
  
  def test_archive_not_logged_in
    get :archive, :id => groups(:private_group).name
    assert_response :not_found, 'private group, not logged in, should not be found'
    
    get :archive, :id => groups(:public_group).name
    assert_response :success, 'public group, not logged in, should be found'
    assert assigns(:group).valid?
  end
  
  def test_archive_logged_in
    login_as :blue

    get :archive, :id => groups(:rainbow).name
    assert_response :success, 'logged in, member of group should succeed'
    assert_template 'archive'
    assert_not_nil assigns(:months)
    assert assigns(:group).valid?
    
    get :archive, :id => groups(:public_group).name
    assert_response :success, 'public group, logged in, should be found'
    assert assigns(:group).valid?

    get :archive, :id => groups(:private_group).name
    assert_response :not_found, 'private group, logged in, should not be found'
  end

  def test_archive_when_not_logged_in
    get :archive, :id => groups(:public_group).name    
    assert_response :success
    assert_template 'archive'
    
    get :archive, :id => groups(:private_group).name
    assert_response :not_found
    assert_template 'not_found'
  end

  def test_member_of_committee_but_not_of_group_cannot_access_group_pages
    User.current = nil
    g = Group.create :name => 'riseup'
    c = Committee.create :name => 'outreach', :parent => g
    g.committees << c
    u = User.create! :login => 'user', :password => 'password', :password_confirmation => 'password'
    assert u.id
    c.memberships.create :user => u
    c.save
    u.reload

    Page.icon 'icon.png' #to avoid a warning
    group_page = Page.create :title => 'a group page', :public => false
    group_page.add(g, :access => :admin)
    group_page.save
    committee_page = Page.create :title => 'a committee page', :public => false, :group => c
    committee_page.add(c, :access => :admin)
    committee_page.save

    @controller.stubs(:current_user).returns(u)
    @controller.stubs(:logged_in?).returns(true)
    @controller.instance_variable_set(:@group, c)
    assert @controller.may_admin_group?

    get :show
    assert_response :success
    assert_template 'show'
    assert_select "h4", "New Pages"
    assert_select "a[href=?]", @controller.page_url(committee_page)

    @controller.instance_variable_set(:@group, g)
    get :show
    assert_select "a[href=?]", @controller.page_url(group_page), false
  end
end
