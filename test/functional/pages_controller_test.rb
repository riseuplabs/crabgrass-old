require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'

# Re-raise errors caught by the controller.
class PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  fixtures :pages, :users

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    login_as :quentin
    get :create
    assert :success
    assert_template 'create'

    num_pages = Page.count

    post :create, :page_type => "Tool::TextDoc", :page => {:title => 'my title'}

    assert_response :redirect
    assert_not_nil assigns(:page)
    assert_redirected_to @controller.page_url(assigns(:page))

    assert_equal num_pages + 1, Page.count
  end
end
