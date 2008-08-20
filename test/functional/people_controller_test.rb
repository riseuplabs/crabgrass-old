require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_index_without_login
    get :index
    assert_response :success
#    assert_template 'list'
    assert_nil assigns(:contacts) 
    assert_nil assigns(:peers) 
  end
  
  def test_index_with_login
    login_as :quentin
    get :index
    assert_response :success
#    assert_template 'list'
    assert_not_nil assigns(:contacts) 
    assert_not_nil assigns(:peers) 
  end
end
