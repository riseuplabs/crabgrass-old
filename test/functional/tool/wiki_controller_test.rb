require File.dirname(__FILE__) + '/../../test_helper'
require 'wiki_page_controller'

# Re-raise errors caught by the controller.
class Tool::WikiController; def rescue_action(e) raise e end; end

class Tool::WikiControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :wikis

  def setup
    @controller = WikiPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

# TODO: write most tests for this controller

  def test_show
    login_as :orange
    get :show, :page_id => pages(:wiki).id
  end
  
  def test_edit
  end

  def test_create
    login_as :quentin
    num_pages = Page.count
    post :create, :page_class=>"WikiPage", :id => 'wiki', :group_id=> "", :create => "Create page", :tag_list => "", 
         :page => {:title => 'my title', :summary => ''}
    assert_response :redirect
    assert_not_nil assigns(:page)
    assert_redirected_to @controller.page_url(assigns(:page))
    assert_equal num_pages + 1, Page.count
  end
end
