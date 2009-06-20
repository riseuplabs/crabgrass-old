require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/participation_controller'

# Re-raise errors caught by the controller.
class BasePage::ParticipationController; def rescue_action(e) raise e end; end

class BasePage::ParticipationControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags


  @@private = AssetExtension::Storage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = AssetExtension::Storage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @controller = BasePage::ParticipationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end

  def test_update_public
    login_as(:blue)
    # blue can edit page 1

    xhr :post, :update_public, :add => true, :page_id => 1
    assert_equal true, Page.find(1).public?
    
    xhr :post, :update_public, :add => false, :page_id => 1
    assert_equal false, Page.find(1).public?
    
    
    # and what if the page has an attachment?
    @asset = Asset.create :uploaded_data => upload_data('photo.jpg'), :page_id => 1
    @asset.save

    xhr :post, :update_public, :add => true, :page_id => 1
    assert_equal true, Page.find(1).public?
    
    xhr :post, :update_public, :add => false, :page_id => 1
    assert_equal false, Page.find(1).public?
    
  end

  def test_add_star
    login_as(:blue)
    post :update_star, :page_id => 1, :add => true
    assert Page.find(1).participation_for_user(users(:blue)).star?
  end
  
  def test_remove_star
    login_as(:blue)
    Page.find(1).participation_for_user(users(:blue)).update_attribute(:star, false)
    post :update_star, :page_id => 1, :add => false
    assert !Page.find(1).participation_for_user(users(:blue)).star?
  end
  
  def test_add_watch
  # TODO: Write this test
  end
  
  def test_remove_watch
    login_as :blue
    post :update_star, :page_id => 1, :add => true # need to get something to set up session variable
    user = @controller.current_user
    
    name = 'my new page'
    page = WikiPage.new do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
    end
    page.save
    page.add(user, :access => :admin)
    page.save!
    
    assert user.may?(:admin, page), "blue should have access to new wiki"
    
    user.share_page_with!(page, user, :send_notice => true) # send a notice to ourselves.
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    assert inbox_pages.find {|p| p.id = page.id}, "new wiki should be in blue's inbox"
    
    post :update_watch, :page_id => page.id, :add => false
    page.reload
    
    assert !page.participation_for_user(user).watch?, 'should not be watched'
  end
  
  def test_destroy
    @owner = users(:blue)
    friend_user = users(:red)
    friend_group = groups(:rainbow)
    @page = Page.create! :title => 'robot tea party', :user => @owner
    assert @page
    @owner.share_page_with!(@page, friend_user, :access => :admin)
    @page.reload
    assert @page.user_ids.include?(friend_user.id)
    @owner.share_page_with!(@page, friend_group, :access => :admin)
    @page.save!
    @page.reload
    assert @page.group_ids.include?(friend_group.id)
    if Conf.ensure_page_owner?
      assert_equal @owner.id, @page.owner_id
    end
    @page.reload

    login_as :blue
    post :destroy, :page_id => @page.id, :upart_id => @page.user_participations.detect{|up|up.user==friend_user}.id
    
    post :destroy, :page_id => @page.id, :gpart_id => @page.group_participations.detect{|gp|gp.group==friend_group}.id
    
    @page = Page.find(@page.id)
    if Conf.ensure_page_owner?
      assert_equal @owner.id, @page.owner_id
    else
      assert_nil @page.owner_id
    end
    assert_equal [@owner.id], @page.user_ids
  end

  def test_destroy_error
    login_as :blue

    owner = users(:green)
    user = users(:blue)
    group = groups(:rainbow)
    page = Page.create! :title => 'robot tea party', :user => owner, :share_with => user
    assert user.may?(:admin, page)

    assert_no_difference 'UserParticipation.count', 'should not be able to delete ourselves' do
      post :destroy, :page_id => page.id, :upart_id => page.participation_for_user(user).id
    end

    owner.share_page_with!(page, group, :access => :admin)
    page.save!
    assert page.participation_for_group(group)
    assert group.may?(:admin, page)

    assert_difference 'UserParticipation.count', -1, 'should be able to delete now' do
      post :destroy, :page_id => page.id, :upart_id => page.participation_for_user(user).id
    end

    assert_no_difference 'GroupParticipation.count', 'should not be able to delete' do
      post :destroy, :page_id => page.id, :gpart_id => page.participation_for_group(group).id
    end

  end

  def test_details
  # TODO: Write this test
  end
  
  def test_show_popup
  # TODO: Write this test
  end
  
  def test_move
    group1 = groups(:animals)
    group2 = groups(:rainbow)
    user = users(:blue)
    page = Page.create! :title => 'snowy snow', :user => user, :share_with => group2, :access => :admin
    login_as :blue
    post :move, :page_id => page.id, :group_id => group2.id
    assert assigns(:page).owner
    assert_equal group2, assigns(:page).owner
  end
  
  def test_share
  # TODO: Write this test
  end
  
 
=begin
# these old tests might be useful in writing a new test for the share function
  def test_notify
    login_as :red
    get :create
    
    post :notify, :id => pages(:page1).id, :to => users(:blue).login, :message => "check out this page"
    assert UserParticipation.find(:all).find { |up| up.user_id == users(:blue).id and up.page_id == pages(:page1).id and up.notice }

  end
  
  def test_add_access
    page = Page.find(1)
    assert page, 'page should exist'

    user = User.find_by_login('red')
    assert user, 'user should exist'
    assert user.may?(:admin, page), 'user should be able to admin page'
    login = login_as(:red)
    assert_equal login, 8, 'should login as user 8'
 
    group = Group.find_by_name('public_group_everyone_can_see')
    assert group, 'group should exist'
    assert !group.may?(:admin, page), 'public group should not have access to page'

    post 'access', :id => page.id, :add_name => group.name
    assert user.may_pester?(group), 'user should be able to pester pub group'
    page.reload
    assert group.may?(:admin, page), 'public group should have access to page'
    
    group_private = Group.find_by_name('private_group')   
    assert group, 'private group should exist'
    assert !group_private.may?(:admin, page), 'private group should not have access to page originally'
 
    post 'access', :id => page.id, :add_name => group_private.name
    page.reload
    assert !group_private.may?(:admin, page), 'private group should still not have access to page'

    post 'access', :id => page.id, :add_name => users(:penguin).name
    page.reload
    users(:penguin).reload
# TODO: figure out why this assert fails intermittently
#    assert users(:penguin).may?(:admin, page), 'user penguin should have access to page'
  end
=end
end
