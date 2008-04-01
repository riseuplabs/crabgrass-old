require File.dirname(__FILE__) + '/../test_helper'
require 'my_calendar_controller'

# Re-raise errors caught by the controller.
class MyCalendarController; def rescue_action(e) raise e end; end

class MyCalendarControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = MyCalendarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # TODO: fill in all stubs for testing this controller
  def test_index
    assert true
  end
  
  def test_day
    assert true
  end

  def test_week
    assert true
  end
  def test_month
    assert true
  end
end
