require File.dirname(__FILE__) + '/../test_helper'
require 'dispatch_controller'

# Re-raise errors caught by the controller.
class DispatchController; def rescue_action(e) raise e end; end

class DispatchControllerTest < Test::Unit::TestCase

  fixtures :pages, :users, :user_participations, :sites, :groups, :memberships

  def setup
    @controller = DispatchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  #really more like a unit test
  def test_find_controller_with_space_and_page_id
    get :dispatch, :_page => 'garble 5'
    assert assigns(:page)
    assert assigns(:page).is_a?(DiscussionPage)
  end

  def test_find_controller_with_plus_and_page_id
    get :dispatch, :_page => 'garble+5'
    assert assigns(:page)
    assert assigns(:page).is_a?(DiscussionPage)
    assert_equal 5, assigns(:page).id
  end

  def test_routes_with_all_numbers
    page = DiscussionPage.create! :name => '2006', :title => '2006', :public => true
    get :dispatch, :_page => '2006'
    assert assigns(:page)
    assert_equal '2006', assigns(:page).name

    get :dispatch, :_page => '+' + page.id.to_s
    assert assigns(:page)
    assert_equal page.id, assigns(:page).id
  end

  # I put this in dispatch_controller_test instead of pages_controller_test
  # because i don't know how to show pages with the pages controller!
  def test_page_actions_appear_correctly
    login_as :blue
    get :dispatch, :_page => 1  # need this to make @controller.current_user = blue
    user = @controller.current_user

    page = Page.find(1)

    assert user.may?(:admin, page), "blue should have access to page 1"
    get :dispatch, :_page => page.id

    # the following is a very brittle test
    # assert_tag 'remove from my inbox'

    post 'pages/remove_from_my_pages/1'
  end

  def test_record_not_found
    login_as :blue
    get :dispatch, :_page => 'fiddleyfoo', :_context => 'blue' 
    assert_response :redirect
  end

  def test_find_by_context_and_name
    login_as :blue
    get :dispatch, :_page  => "committee_page", :_context => 'rainbow the-warm-colors'
    assert_response :success

    get :dispatch, :_page => 'rainbow_page', :_context => 'rainbow'
    assert_response :success

    get :dispatch, :_page => 'blue_page', :_context => 'blue'
    assert_response :success
  end

end
