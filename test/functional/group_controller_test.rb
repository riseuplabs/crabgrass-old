require File.dirname(__FILE__) + '/../test_helper'
require 'group_controller'
#showlog
# Re-raise errors caught by the controller.
class GroupController; def rescue_action(e) raise e end; end

class GroupControllerTest < Test::Unit::TestCase
  fixtures :groups, :group_settings, :users, :memberships, :profiles, :pages, :group_participations, :user_participations, :tasks, :page_terms

  include UrlHelper

  def setup
    @controller = GroupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_when_logged_in
    login_as :red
    
    # show a group you belong to
    get :show, :id => groups(:rainbow).name
    assert_response :success
#    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?

    assert_not_nil assigns(:access)
    assert_equal :private, assigns(:access), "blue should have access to private group information for :rainbow"
    
    #show a committee you belong to
    get :show, :id => groups(:warm).name
    assert_response :success
#    assert_template 'show'
    assert assigns(:group).valid?
    
    # show a public group you don't belong to
    get :show, :id => groups(:public_group).name
    assert_response :success
#    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?

    assert_not_nil assigns(:access)
    assert_equal :public, assigns(:access), "blue should only have access to public group information for :public_group"
    
    # show nothing for a private group you don't belong to
    get :show, :id => groups(:private_group).name
    assert_response :success
#    assert_template 'show_nothing'
  end

  def test_show_committees_when_logged_in
    login_as :blue
    
    # show a group you belong to
    get :show, :id => groups(:public_group).name
    assert_response :success
#    assert_template 'show'

    assert_equal :private, assigns(:access), "should have private access to public group"
    assert_equal 2, assigns(:committees).length, "should show 2 committee"
    
  end

  def test_show_public_when_not_logged_in
    get :show, :id => groups(:public_group).name    
    assert_response :success
#    assert_template 'show'
    assert_equal :public, assigns(:access), "should have public access to public group"
    assert_equal 1, assigns(:committees).length, "should show 1 committee"
    
    get :show, :id => groups(:public_committee).name
    assert_response :success
#    assert_template 'show'
    assert_equal :public, assigns(:access), "should have public access to public committee of public group"
  end

  def test_show_private_when_not_logged_in
    get :show, :id => groups(:private_group).name
    assert_response :success
    assert_nil assigns(:access), "should have no access to private group"
    
    get :show, :id => groups(:warm).name
    assert_response :success
    assert_nil assigns(:access), "should have no access to private committee"

    get :show, :id => groups(:private_committee).name
    assert_response :success
    assert_nil assigns(:access), "should have no access to private committee of public group"    
  end

  def test_visualize
  end
  
  def test_archive_logged_in
    login_as :red

    get :archive, :id => groups(:rainbow).name
    assert_response :success, 'logged in, member of group should succeed'
#    assert_template 'archive'
    assert assigns(:group).valid?
    assert_not_nil assigns(:months)
    assert assigns(:months).length > 0, "should have some months"
    
    get :archive, :id => groups(:public_group).name
    assert_response :success, 'public group, logged in, should be found'
    assert assigns(:group).valid?

    get :archive, :id => groups(:public_group).name, :path => 'month/1/year/2008'
    assert_response :success
#    assert_template 'archive'

    get :archive, :id => groups(:private_group).name
#    assert_template 'show_nothing', 'private group, logged in, should not be found'
  end

  def test_archive_not_logged_in
    get :archive, :id => groups(:public_group).name    
    assert_response :success
#    assert_template 'archive'
    
    get :archive, :id => groups(:private_group).name
#    assert_template 'show_nothing'
  end


  def test_search
    login_as :blue

    get :search, :id => groups(:rainbow).name
    assert_response :success
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results"
    
    get :search, :id => groups(:rainbow).name, :path => 'type/discussion'
    assert_response :success
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results when filter for discussions"
    
    post :search, :id => groups(:rainbow).name, :search => {:text => "e", :type => "", :person => "", :month => "", :year => "", :pending => "", :starred => ""}
    assert_response :redirect
    assert_redirected_to 'group/search/rainbow/text/e'
    assert_not_nil assigns(:pages)
    assert assigns(:pages).length > 0, "should have some search results when filter for text"
  end

  def test_search_when_not_logged_in
    get :search, :id => groups(:public_group).name
    assert_response :success
    
    post :search, :id => groups(:public_group).name, :search => {:text => "e", :type => "", :person => "", :month => "", :year => "", :pending => "", :starred => ""}
    assert_response :redirect
    assert_redirected_to "group/search/#{groups(:public_group).name}/text/e"
  end
  
  def test_tags
    login_as :blue
    
    get :tags, :id => groups(:rainbow).name
    assert_response :success
#    assert_template 'tags'
    assert_not_nil assigns(:pages)
  end

  def test_tasks
    login_as :blue
    
    get :tasks, :id => groups(:rainbow).name
    assert_response :success
#    assert_template 'tasks'
    assert_not_nil assigns(:pages)
    assert_not_nil assigns(:task_lists)
    assert assigns(:pages).length > 0, "should find some tasks"
  end

  def test_edit
    login_as :blue
    get :edit, :id => groups(:rainbow).name

    assert_response :success
#    assert_template 'edit'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
    
    new_name = "not-rainbow"
    new_full_name = "not a rainbow"
    new_summary = "new summary"
    
    group = Group.find(groups(:rainbow).id)
    
    post :update, :id => groups(:rainbow).name, :group => {:full_name => new_full_name, :name => new_name, :summary => new_summary}
    assert_response :redirect
    assert_redirected_to :action => 'edit', :id => groups(:rainbow)
    
    group.reload
    assert_equal new_full_name, group.full_name, "full name should now be '#{new_full_name}'"
    assert_equal new_name, group.name, "group name should now be '#{new_name}'"
    assert_equal new_summary, group.summary, "summary should now be '#{new_summary}'"
    
    # a sneaky hacker attack to watch out for
    Group.create! :name => 'hack-committee', :full_name => "hacker!", :summary => ""
    assert_not_nil Group.find_by_name('hack-committee')
    post :edit, :id => 'hack-committee', :group => {:parent_id => groups(:rainbow).id}
    assert_nil Group.find_by_name('hack-committee').parent
  end

  def test_update
    login_as :blue
    post :update, :id => groups(:rainbow).name
    assert_response :redirect
    assert_redirected_to :action => 'edit', :id => groups(:rainbow).name
    
    # try changing the visibility settings
    post :update, :id => groups(:private_group).name,
            :group => { :publicly_visible_group => "1",
                        :publicly_visible_members => "1",
                        :publicly_visible_committees => "1",
                        :accept_new_membership_requests => "1" }
    groups(:private_group).reload
    assert_equal true, groups(:private_group).publicly_visible_group,
                   "private group should be public now"
    assert_equal true, groups(:private_group).publicly_visible_committees,
                   "private group should have public committees now"
    assert_equal true, groups(:private_group).publicly_visible_members,
                   "private group should have public membership now"
    assert_equal true, groups(:private_group).accept_new_membership_requests,
                   "private group should accept new membership requests"

    # make sure changing back works, too
    post :update, :id => groups(:private_group).name,
            :group => { :publicly_visible_group => "0",
                        :publicly_visible_members => "0",
                        :publicly_visible_committees => "0",
                        :accept_new_membership_requests => "0" }
    groups(:private_group).reload
    assert_equal false, groups(:private_group).publicly_visible_group,
                   "private group should be private again"
    assert_equal false, groups(:private_group).publicly_visible_committees,
                   "private group should not have public committees now"
    assert_equal false, groups(:private_group).publicly_visible_members,
                   "private group should not have public membership now"
    assert_equal false, groups(:private_group).accept_new_membership_requests,
                   "private group should not accept new membership requests"

    
    # try a sneaky hacker attack
    Group.create! :name => 'hack-committee', :full_name => "hacker!", :summary => ""
    assert_not_nil Group.find_by_name('hack-committee')
    post :update, :id => 'hack-committee', :group => {:parent_id => groups(:rainbow).id}
    assert_nil Group.find_by_name('hack-committee').parent
  end

  def test_edit_tools
    login_as :blue
    
    post :edit_tools, :id => groups(:rainbow).name, :Discussion => "on", :Message => "on", :Wiki => "on"
    groups(:rainbow).reload
    assert_equal true, groups(:rainbow).group_setting.allowed_tools.include?("Discussion"),
                   "group should have Discussion page allowed"
    assert_equal true, groups(:rainbow).group_setting.allowed_tools.include?("Message"),
                   "group should have Message page allowed"
    assert_equal true, groups(:rainbow).group_setting.allowed_tools.include?("Wiki"),
                   "group should have Wiki page allowed"
    assert_equal false, groups(:rainbow).group_setting.allowed_tools.include?("Asset")
                   "group should not have Asset page allowed" 
  end

  def test_destroy
    login_as :gerrard
    
    assert_no_difference 'Group.count', "need to be only member to destroy a group" do
      post :destroy, :id => groups(:true_levellers).id
    end
    
    group_name = 'short-lived-group'
    
    group = Group.create! :name => group_name
    group.add_user! users(:gerrard)
    
    assert_difference 'Group.count', -1, "should delete newly created group" do
      post :destroy, :id => group_name
      assert_redirected_to :controller => 'groups'
    end
  end

  def test_login_required
    [:create, :edit, :destroy, :update].each do |action|
      assert_requires_login do |c|
        c.get action, :id => groups(:public_group).name
      end
    end

# should we test unlogged-in stuff on a private group?
#    [:create, :edit, :destroy, :update].each do |action|
#      get action, :id => groups(:private_group).name
#      assert_template 'not_found'
#    end
  end

  def test_member_of_committee_but_not_of_group_cannot_access_group_pages
    User.current = nil
    g = Group.create :name => 'riseup'
    c = Committee.create :name => 'outreach', :parent => g
    g.add_committee!(c)
    u = User.create! :login => 'user', :password => 'password', :password_confirmation => 'password'
    assert u.id
    c.add_user! u
    c.save
    u.reload

    group_page = DiscussionPage.create :title => 'a group page', :public => false
    group_page.add(g, :access => :admin)
    group_page.save
    committee_page = DiscussionPage.create :title => 'a committee page', :public => false, :group => c
    committee_page.add(c, :access => :admin)
    committee_page.save

    @controller.stubs(:current_user).returns(u)
    @controller.stubs(:logged_in?).returns(true)
    @controller.instance_variable_set(:@group, c)
    assert u.may_admin?(c)
    assert @controller.may_admin_group?

    get :show
    assert_response :success
    assert_select "td.date", "Today"
    assert_select "a[href=?]", @controller.page_url(committee_page)

    @controller.instance_variable_set(:@group, g)
    get :show
    assert_select "a[href=?]", @controller.page_url(group_page), false
  end

end
