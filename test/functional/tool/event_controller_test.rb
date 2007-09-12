require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/event_controller'

# Re-raise errors caught by the controller.
class Tool::EventController; def rescue_action(e) raise e end; end

class Tool::EventControllerTest < Test::Unit::TestCase
  fixtures :pages, :users

  def setup
    @controller = Tool::EventController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    login_as :quentin
    num_pages = Page.count
    post :create, :page_type => "Tool::Event", :id => 'event', :page => {:title => 'my title event' }
    assert_response :success
    assert_not_nil assigns(:page)
    assert_equal num_pages + 1, Page.count
  end

  def test_get_create
    login_as :quentin
    get :create, {:action => "create", "id"=>"event", "controller"=>"tool/event"}
    assert_response :success
    assert assigns(:event)
    assert assigns(:page_class)
    assert assigns(:event).new_record?
  end

  def test_create_login_required
    get :create, {:action => "create", "id"=>"event", "controller"=>"tool/event"}
    assert_response 302
  end


  #starts_at < ends_at if all_day is false

  #
end
