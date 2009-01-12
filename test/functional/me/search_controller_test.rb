require File.dirname(__FILE__) + '/../../test_helper'
require 'me/search_controller'

# Re-raise errors caught by the controller.
class Me::SearchController; def rescue_action(e) raise e end; end

class MeSearchControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :tasks, :task_participations, :task_lists, :page_terms

  def setup
    @controller = Me::SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    login_as :blue

    get :index
    assert_response :success
 end
 
 def test_text_search
    return unless sphinx_working?(:test_text_search)
    login_as :blue

    get :index, :path => ["text", "test"]
    assert_response :success
    assert assigns(:pages).any?, "should find a page"
    assert_not_nil assigns(:pages)[0].flag[:excerpt], "should generate an excerpt"
  end

 def test_text_search_and_sort
    return unless sphinx_working?(:test_text_search_and_sort)
    login_as :blue

    get :index, :path => ["text", "test", "ascending", "group_name"]
    assert_response :success
    assert assigns(:pages).any?, "should find a page"
    assert_not_nil assigns(:pages)[0].flag[:excerpt], "should generate an excerpt"
  end

end
