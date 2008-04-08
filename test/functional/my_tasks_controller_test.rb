require File.dirname(__FILE__) + '/../test_helper'
require 'my_tasks_controller'

# Re-raise errors caught by the controller.
class MyTasksController; def rescue_action(e) raise e end; end

class MyTasksControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :tasks, :tasks_users, :task_lists

  def setup
    @controller = MyTasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


  def test_login_required
    [:index, :pending, :completed, :group].each do |action|
      get action
      assert_redirected_to :controller => 'account', :action => 'login'
    end
  end
  
  def test_index
    login_as :blue
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_tag :tag => "li", :attributes => { :id => "task_4" }
    assert_no_tag :tag => "li", :attributes => { :id => "task_5" }
    assert_tag :tag => "li", :attributes => { :id => "task_6" }
  end
  
  def test_pending
    login_as :blue
    get :pending
    assert_response :success
    assert_template 'index'
    assert assigns(:pages).length > 0, "there should be pending tasks for blue"
  end

  def test_completed
    login_as :blue
    get :completed
    assert_response :success
    assert_template 'index'
    assert assigns(:pages).length > 0, "there should be a completed task for blue"
    assert_no_tag :tag => "li", :attributes => { :id => "task_4" }
    assert_tag :tag => "li", :attributes => { :id => "task_5" }
    assert_no_tag :tag => "li", :attributes => { :id => "task_6" }
  end

  def test_group
    login_as :blue
    get :group, :id => groups(:rainbow).id
    assert_response :success
    assert_template 'index'
    assert assigns(:pages).length > 0, "rainbow group has tasks"

    get :group, :id => groups(:true_levellers).id
    assert_response :success
    assert_template 'index'
    assert assigns(:pages).length == 0, "true_levellers group has no tasks"
  end
end
