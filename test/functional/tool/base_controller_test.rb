require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page_controller'

# Re-raise errors caught by the controller.
class BasePageController; def rescue_action(e) raise e end; end

class Tool::BaseControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = BasePageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_without_login
    get :create, :id => 'wiki'
    assert_redirected_to :controller => 'account', :action => 'login'
    
    post :create, :id => 'wiki'
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_create_with_login
    login_as :orange
    
    get :create, :id => 'wiki'
    assert_template 'base_page/create'
  
    assert_difference 'Page.count' do
      post :create, :id => 'wiki', :page => { :title => 'test title' }
      assert_response :redirect
    end
  end

  def test_set_title
    login_as(:red)
    post :title, :page_id => 1, :page => {:title => "new title"}
    assert_equal "new title", Page.find(1).title
  end

  def test_set_summary_ajax
    login_as :red
    xhr :post, :summary, :page_id => 1, :page => {:summary => "new summary"}    
    assert_equal "new summary", Page.find(1).summary
  end

  def test_set_summary_without_ajax
    login_as :red
    post :summary, :page_id => 1, :page => {:summary => "new summary"}    
    assert_equal "new summary", Page.find(1).summary
  end
end
