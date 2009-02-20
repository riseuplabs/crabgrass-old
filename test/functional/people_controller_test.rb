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
    %w(index contacts peers directory).each do |action|
      get action
      assert_response :success
#    assert_template 'list'
      assert_nil assigns(:users)
    end

  end

  def test_index_with_login
    login_as :quentin
    %w(index contacts peers directory).each do |action|
      get action
      assert_response :success
      assert_not_nil assigns(:users)
    end
  end
end
