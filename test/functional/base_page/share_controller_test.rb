require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/share_controller'

# Re-raise errors caught by the controller.
class BasePage::ShareController; def rescue_action(e) raise e end; end

class BasePage::ShareControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags


  @@private = AssetExtension::Storage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = AssetExtension::Storage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @controller = BasePage::ShareController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end

  # tests that the share popup loads
  def test_show_share_popup
    login_as :blue
    xhr :post, :show_popup, :name => 'share', :page_id => 1, :page => "640x480", :position => "60x20"
    assert_response :success
  end
  
  # tests thate the notify popup loads
  def test_show_notify_popup
    login_as :blue
    xhr :post, :show_popup, :name => 'notify', :page_id => 1, :page => "640x480", :position => "60x20"
    assert_response :success
  end
  
  
  # tests if it's possible to add recipients from the share popup
  def test_add_recipient
    login_as :blue
    
    # a request that should be successful
    xhr :post, :update, { :page_id =>  1, :recipient => {:name => 'penguin' } } 
    assert_response :success
    assert_select 'li.unsaved'
    
    # this request should not end in adding the user a second time
    
    # a request that will not be successful, as the username doesn't exist.
    xhr :post, :update, { :page_id =>  1, :recipient => {:name => 'a_username_that_will_never_exist' } } 
    assert_response :success
    assert_select 'div.error'
    
    # a request that should lead in an error because i may not pester that user
    user1 = User.find_by_login 'penguin'
    user2 = User.find_by_login 'yellow'
    login_as :penguin
    assert !user1.may_pester?(user2), 'user1 should not be allowed to pester user2'
    xhr :post, :update, { :page_id =>  1, :recipient => {:name => 'yellow' } } 
    assert_response :success
    assert_select 'div.error'
  end
  
  def test_add_access
    # setup user and page
    page = Page.find(1)
    assert page, 'page should exist (load the fixtures first, dumbass!!)'

    user = User.find_by_login('red')
    assert user, 'user should exist'
    assert user.may?(:admin, page), 'user should be able to admin page'
    login = login_as(:red)
    assert_equal login, 8, 'should login as user 8'
    
    # get a public group without access to the page
    group = Group.find_by_name('public_group_everyone_can_see')
    assert group, 'group should exist'
    assert !group.may?(:admin, page), 'public group should not have access to page'
   
    # share the page with the group, and give admin-access to the group
    assert user.may_pester?(group), 'user should be able to pester pub group'
    xhr :post, :update, { :page_id => page.id, :recipients => { group.name.to_sym => { :access => :admin } } }
    page.reload
    assert group.may?(:admin, page), 'public group should have access to page'
    
    # get a private group. and try tp share with it
    group_private = Group.find_by_name('private_group_not_everyone_can_see')   
    assert group, 'private group should exist' 
    assert !group_private.may?(:admin, page), 'private group should not have access to page originally'
 
    xhr :post, :update , { :page_id => page.id, :recipients => { group.name.to_sym => { :access => :admin } } }
    page.reload
    assert !group_private.may?(:admin, page), 'private group should still not have access to page'

    # try to share with a user
    xhr :post, :update , { :page_id => page.id, :recipients => { users(:penguin).login.to_sym => { :access => :admin } } }
    page.reload
    users(:penguin).reload
    assert users(:penguin).may?(:admin, page), 'user penguin should have access to page'
    
    # try to share with a committe (#bugfixing a problem caused by the "+" in the committee name
    xhr :post, :update , { :page_id => page.id, :recipients => { "rainbow+the-warm-colors".to_sym => { :access => :admin } } }
    assert :success
    
    # when the page is already shared with a user, it should not be possible to add it again as a recipient
    xhr :post, :update, { :page_id =>  page.id, :recipient => {:name => 'penguin' } }
    assert_response :success
    assert_select 'div.error'
        
  end
  
  # test if notifying an existing user works
  def test_notification
    login_as :blue
    page = Page.find(1)
    assert page, 'page should exist (load the fixtures first, dumbass!!)'
    user1 = User.find_by_login('blue')
    user2 = User.find_by_login('red')
    
    # assert that a UserParticipation for the User and Page already exists
    upart = UserParticipation.find_by_page_id_and_user_id(page.id, user2.id)
    assert upart, 'the userparticipation should already exist to notify the user'
    
    # try to push the participation to inbox
    xhr :post, :update, { :page_id =>  1, :recipients => {user2.login.to_sym  => {:send_notice => 1} }, :notification => {:notify_contributors => 1, :include_message => 1, :send_notice => 1 }, :message => 'additional_message' }
    assert_response :success
    upart.reload
    assert upart.inbox, 'participation.inbox should be set to true now'
  end
  
end
