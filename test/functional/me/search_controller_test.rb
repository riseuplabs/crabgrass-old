require File.dirname(__FILE__) + '/../../test_helper'
require 'me/search_controller'

# Re-raise errors caught by the controller.
class Me::SearchController; def rescue_action(e) raise e end; end

class MeSearchControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :page_indices, :tasks, :task_participations, :task_lists

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
    login_as :blue

    get :index, :path => ["text", "inar"]
    assert_response :success
    assert_not_nil assigns(:pages), "should find a page"
    
    if ThinkingSphinx.updates_enabled?
      assert_not_nil assigns(:excerpts), "should generate an excerpt"
    end
  end

 def test_text_search_and_sort
    login_as :blue

    get :index, :path => ["text", "inar", "ascending", "group_name"]
    assert_response :success
    assert_not_nil assigns(:pages), "should find a page"
    
    if ThinkingSphinx.updates_enabled?
      assert_not_nil assigns(:excerpts), "should generate an excerpt"
    end
  end

end
