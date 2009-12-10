require File.dirname(__FILE__) + '/../test_helper'
require 'person_controller'

# Re-raise errors caught by the controller.
class PersonController; def rescue_action(e) raise e end; end

class PersonControllerTest < Test::Unit::TestCase
  fixtures :users, :pages, :sites, :profiles

  def setup
    @controller = PersonController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    #Page.all.each {|p| p.update_page_terms}
  end

  def test_show_not_logged_in
    get :show, :id => users(:red).login
    assert_response :success
    assert_nil assigns(:pages).find { |p| !p.public? }
  end

  def test_show_logged_in
    login_as :dolphin
    get :show, :id => users(:orange).login
    assert_response :success
    assert_nil assigns(:pages).find { |p| !(p.public? or users(:dolphin).may?(:view, p)) }
  end

  def test_search_not_logged_in
    # note: if yellow doesn't have a public profile, you will get weird results.
    get :search, :id => users(:yellow).login
    assert_response :success
    assert_not_nil assigns(:pages)
    assert_nil assigns(:pages).find { |p| !p.public? }
  end

  def test_search_logged_in
    login_as :penguin
    get :search, :id => users(:green).login
    assert_not_nil assigns(:pages)
    assert_response :success
    assert_nil assigns(:pages).find { |p| !(p.public? or users(:penguin).may?(:view, p)) }
  end

  def test_tasks_not_logged_in
    get :tasks, :id => users(:blue).login
    assert_response :success
#    assert_template 'tasks'
    assert_nil assigns(:pages).find { |p| !p.is_a?(TaskListPage) }
    assert_nil assigns(:pages).find { |p| !p.public? }
  end

  def test_tasks_logged_in
    login_as :quentin
    get :tasks, :id => users(:purple).login
    assert_response :success
#    assert_template 'tasks'
    assert_nil assigns(:pages).find { |p| !p.is_a?(TaskListPage) }
    assert_nil assigns(:pages).find { |p| !users(:quentin).may?(:view, p) }
  end
end
