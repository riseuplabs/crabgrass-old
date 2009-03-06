require File.dirname(__FILE__) + '/../../test_helper'
require 'me/tasks_controller'

# Re-raise errors caught by the controller.
class Me::TasksController; def rescue_action(e) raise e end; end

class MeTasksControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :tasks, :task_participations, :task_lists

  def setup
    @controller = Me::TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login_required
    [:pending, :completed].each do |action|
      get action
      assert_redirected_to :controller => 'account', :action => 'login'
    end
  end  
 
  def test_pending
    login_as :blue
    get :pending
    assert_response :success
#    assert_template 'list'
    assert assigns(:pages).length > 0, "there should be pending tasks for blue"
  end

  def test_completed
    login_as :blue
    get :completed
    assert_response :success
#    assert_template 'list'
    assert assigns(:pages).length > 0, "there should be a completed task for blue"
    assert_no_tag :tag => "li", :attributes => { :id => "task_4" }
    assert_tag :tag => "li", :attributes => { :id => "task_5" }
    assert_no_tag :tag => "li", :attributes => { :id => "task_6" }
  end

end
