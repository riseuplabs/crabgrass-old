require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/wiki_controller'

# Re-raise errors caught by the controller.
class Tool::WikiController; def rescue_action(e) raise e end; end

class Tool::WikiControllerTest < Test::Unit::TestCase
  fixtures :pages, :users

  def setup
    @controller = Tool::WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    login_as :quentin
    num_pages = Page.count
    post :create, :page_type => "Tool::TextDoc", :id => 'wiki', :page => {:title => 'my title'}
    assert_response :redirect
    assert_not_nil assigns(:page)
    assert_redirected_to @controller.page_url(assigns(:page))
    assert_equal num_pages + 1, Page.count
  end
end
