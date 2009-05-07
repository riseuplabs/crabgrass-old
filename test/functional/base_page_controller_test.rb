require File.dirname(__FILE__) + '/../test_helper'
require 'base_page_controller'

# showlog

# Re-raise errors caught by the controller.
class BasePageController; def rescue_action(e) raise e end; end

class Tool::BasePageControllerTest < Test::Unit::TestCase
  fixtures :pages, :groups, :users, :memberships, :group_participations, :user_participations, :sites

  def setup
    @controller = BasePageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_without_login
    get :create, :id => WikiPage.param_id
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'
    
    post :create, :id => WikiPage.param_id
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_create_with_login
    login_as :orange
    
    get :create, :id => WikiPage.param_id
    assert_response :success
  
    assert_difference 'Page.count' do
      post :create, :id => 'wiki', :page => { :title => 'test title' }
      assert_response :redirect
    end
  end

  def test_page_creation_access
    login_as :kangaroo
    post :create, {"id"=>DiscussionPage.param_id, "action"=>"create", "page"=>{"title"=>"aaaa"}, "recipients"=>{"animals"=>"1"}, "controller"=>"discussion_page", "access"=>"view", "create"=>"Create discussion »"}
    page = assigns(:page)
    assert page
    assert users(:kangaroo).may?(:admin,page)
    assert groups(:animals).may?(:view,page)
    assert !groups(:animals).may?(:admin,page), 'group must not have admin access'
  end

end
