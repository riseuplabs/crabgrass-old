require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase

  def setup
  end

  def test_creation
    assert list = Task::TaskList.create
    assert list.tasks.create
  end

  def test_deletion
    list = Task::TaskList.create
    list.tasks.create
    id = list.tasks.first.id
    list.destroy
    assert_nil Task::Task.find_by_id(id), 'deleting the list should delete the tasks'
  end

  def test_associations
    assert check_associations(Task::TaskList)
    assert check_associations(Task::Task)
    assert check_associations(Task::TasksUser)
  end
  
end
