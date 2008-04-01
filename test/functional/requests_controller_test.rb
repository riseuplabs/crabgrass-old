require File.dirname(__FILE__) + '/../test_helper'
require 'requests_controller'

# Re-raise errors caught by the controller.
class RequestsController; def rescue_action(e) raise e end; end

class RequestsControllerTest < Test::Unit::TestCase
  fixtures :groups, :pages, :users, :memberships
  
  def setup
    @controller = RequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # TODO: Add fixtures for requests to make results in all of these categories

  def test_index
    login_as :blue
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:my_pages)
  end

  def test_mine
    login_as :blue
    get :mine, :path => []
    assert_response :success
    assert_template 'more'
#    assert_not_nil assigns(:pages)
  end
  
  def test_contacts
    login_as :blue
    get :contacts, :path => []
    assert_response :success
    assert_template 'more'
#    assert_not_nil assigns(:pages)
  end

  def test_memberships
    login_as :blue
    get :memberships, :path => []
    assert_response :success
    assert_template 'more'
#    assert_not_nil assigns(:pages)
  end

  def test_more
    login_as :blue
    get :more
    assert_response :success
    assert_template 'more'
#    assert_not_nil assigns(:pages)
  end
end
