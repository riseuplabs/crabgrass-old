require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/participation_controller'

# Re-raise errors caught by the controller.
class BasePage::ParticipationController; def rescue_action(e) raise e end; end

class BasePage::ParticipationControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags


  @@private = Media::AssetStorage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = Media::AssetStorage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

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

    xhr :post, :update_public, :public => 'true', :page_id => 1
    assert_equal true, Page.find(1).public?
    
    xhr :post, :update_public, :public => 'null', :page_id => 1
    assert_equal false, Page.find(1).public?
    
    
    # and what if the page has an attachment?
    @asset = Asset.create :uploaded_data => upload_data('photo.jpg'), :page_id => 1
    @asset.save

    xhr :post, :update_public, :public => 'true', :page_id => 1
    assert_equal true, Page.find(1).public?
    
    xhr :post, :update_public, :public => 'null', :page_id => 1
    assert_equal false, Page.find(1).public?
    
  end

  def test_add_star
  # TODO: Write this test
  end
  
  def test_remove_star
  # TODO: Write this test
  end
  
  def test_add_watch
  # TODO: Write this test
  end
  
  def test_remove_watch
    login_as :blue
    get :details, :page_id => 1 # need to get something to set up session variable
    user = @controller.current_user
    
    name = 'my new page'
    page = WikiPage.new do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
    end
    page.save
    page.add(user)
    page.save!
    
    assert user.may?(:admin, page), "blue should have access to new wiki"
    
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    assert inbox_pages.find {|p| p.id = page.id}, "new wiki should be in blue's inbox"
    
    post :remove_watch, :page_id => page.id
    page.reload
    
    # TODO: Figure out what the intended effect of removing a watch should be, and test for it
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    #  assert inbox_pages.find {|p| p.id == page.id} == nil, "new wiki should not be in blue's inbox"
    
    assert user.may?(:admin, page), "blue should still have access to new wiki"
  end
  
  def test_details
  # TODO: Write this test
  end
  
  def test_show_popup
  # TODO: Write this test
  end
  
  def test_move
  # TODO: Write this test
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
    
    group_private = Group.find_by_name('private_group_not_everyone_can_see')   
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
