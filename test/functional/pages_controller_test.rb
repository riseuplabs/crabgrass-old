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
    pg = Page.find(1)
    assert pg, 'page should exist'

    user = User.find_by_login('orange')
    assert user, 'user should exist'
    assert user.may?(:admin, pg), 'user should be able to admin page'
    login = login_as(:orange)
    assert_equal login, 5, 'should login as user 5'
 
    group = Group.find_by_name('public_group_everyone_can_see')
    assert group, 'group should exist'
    assert !group.may?(:admin, pg), 'public group should not have access to page'

    post 'access', :id => pg.id, :add_name => group.name
    assert user.may_pester?(group), 'user should be able to pester pub group'
    pg.reload
    assert group.may?(:admin, pg), 'public group should have access to page'
    
    group_private = Group.find_by_name('private_group_not_everyone_can_see')   
    assert group, 'private group should exist'
    assert !group_private.may?(:admin, pg), 'private group should not have access to page originally'
 
    post 'access', :id => pg.id, :add_name => group_private.name
    pg.reload
    assert !group_private.may?(:admin, pg), 'private group should still not have access to page'
  end
end
