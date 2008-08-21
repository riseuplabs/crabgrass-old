require File.dirname(__FILE__) + '/../../test_helper'
require 'me/inbox_controller'

# Re-raise errors caught by the controller.
class Me::InboxController; def rescue_action(e) raise e end; end

class InboxControllerTest < Test::Unit::TestCase
  fixtures :users, :user_participations, :groups, :group_participations, :pages

  def setup
    @controller = Me::InboxController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index_without_logging_in
    get :index
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end
  
  def test_index
    login_as :blue
    get :index
    assert_response :success
#    assert_template 'list'
    assert assigns(:pages).length > 0
    
    get :index, :path => ['ascending', 'title']
    assert_response :success
#    assert_template 'list'
    assert assigns(:pages).length > 0
    
    get :index, :path => ['unread']
    assert_response :success
#    assert_template 'list'
    assert assigns(:pages).length > 0
    
  end

  def test_remove_by_posting_to_index
    login_as :blue
    get :index
    assert assigns(:pages).length > 0
    
    removed_page_id = assigns(:pages).first.id
    puts assigns(:pages).clear
    post :update, :page_checked => { removed_page_id.to_s => "checked"}, :remove => true
    assert_nil assigns(:pages).find {|p| p.id == removed_page_id },
               "page #{removed_page_id} shouldn't be in the inbox anymore"
  end

  # stubs for testing actions
  # fill in when we know what they are supposed to do
  def test_update
  end

  def test_remove
    assert true
  end
end
