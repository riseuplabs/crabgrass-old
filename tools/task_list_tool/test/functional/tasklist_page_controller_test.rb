require File.dirname(__FILE__) + '/../../../../test/test_helper'

class TaskListPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :task_lists, :tasks

  def text_show
    login_as :quentin

    get :show, :page_id => pages(:tasklist1)
    assert_response :success
#    assert_template 'task_list_page/show'
  end

  def test_sort
    login_as :blue

    @user = users(:blue)
    @page = pages(:tasklist1)
    @page.add(@user, :access => :admin)
    @page.save!

    assert_equal 1, Task.find(1).position
    assert_equal 2, Task.find(2).position
    assert_equal 3, Task.find(3).position

    xhr :post, :sort, :controller => "task_list_page", :page_id => @page.id, :id => 0, :sort_list_pending => ["3","2","1"]
    assert_response :success

    assert_equal 3, Task.find(1).position
    assert_equal 2, Task.find(2).position
    assert_equal 1, Task.find(3).position
  end

  def text_multi_list_sort
    login_as :blue

    pages(:tasklist1).add(users(:blue), :access => :admin)
    pages(:tasklist2).add(users(:blue), :access => :admin)
    pages(:tasklist1).save!
    pages(:tasklist2).save!

    tasks = Task.find(1,2,3,4,5,6).index_by {|t| t.id}
    assert_equal tasks[1].position, 1
    assert_equal tasks[2].position, 2
    assert_equal tasks[3].position, 3
    assert_equal tasks[4].position, 1
    assert_equal tasks[5].position, 2
    assert_equal tasks[6].position, 3
    assert_not_equal tasks[2].task_list_id, tasks[4].task_list_id

    xhr :post, :sort, :controller => "task_list_page", :page_id => pages(:tasklist1).id, :id => 0, :sort_list_21_pending => ["1","3"]
    @controller = TaskListPageController.new
    xhr :post, :sort, :controller => "task_list_page", :page_id => pages(:tasklist2).id, :id => 0, :sort_list_22_pending => ["4","5","2","6"]

    tasks = Task.find(1,2,3,4,5,6).index_by {|t| t.id}
    assert_equal tasks[1].position, 1
    assert_equal tasks[2].position, 3
    assert_equal tasks[3].position, 2
    assert_equal tasks[4].position, 1
    assert_equal tasks[5].position, 2
    assert_equal tasks[6].position, 4
    assert_equal tasks[2].task_list_id, tasks[4].task_list_id
  end

  def text_create_task
    login_as :blue
    pages(:tasklist1).add(users(:blue), :access => :admin)
    pages(:tasklist1).save!
    assert_difference 'pages(:tasklist1).data.tasks.count' do
      xhr :post, :create_task, :controller => "task_list_page", :page_id => pages(:tasklist1).id, :task => {:name => "new task", :user_ids => ["5"], :description => "new task description"}
    end
  end

  # TODO: tests for mark_task_complete, mark_task_pending, destroy_task, update_task, edit_task

end
