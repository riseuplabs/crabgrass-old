require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'

# Re-raise errors caught by the controller.
class PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :groups, :group_participations, :memberships, :profiles

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    login_as :quentin
    get :create
    assert :success
    assert_template 'create'
  end
  
  def test_login_required
    [:tag, :notify, :access, :move, :destroy].each do |action|
      assert_requires_login do |c|
        c.get action, :id => pages(:hello).id
      end
    end
  end
  
  def test_add_access
    page = Page.find(1)
    assert page, 'page should exist'

    user = User.find_by_login('orange')
    assert user, 'user should exist'
    assert user.may?(:admin, page), 'user should be able to admin page'
    login = login_as(:orange)
    assert_equal login, 5, 'should login as user 5'
 
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
  end
  

  def test_remove_from_my_inbox
    login_as :blue
    get :create  # need this to make @controller.current_user = blue
    user = @controller.current_user
    
    name = 'my new page'
    page = Tool::TextDoc.new do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
    end
    page.save
    page.add(user)
    page.save!
    
    assert user.may?(:admin, page), "blue should have access to new wiki"
    
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    assert_equal page.id, inbox_pages.first.id, "new wiki should be first thing in blue's inbox"
    
    post 'remove_from_my_pages', :id => page.id
    page.reload
    
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    assert inbox_pages.find {|p| p.id == page.id} == nil, "new wiki should not be in blue's inbox"
    
    assert user.may?(:admin, page), "blue should still have access to new wiki"
  end
  
end
