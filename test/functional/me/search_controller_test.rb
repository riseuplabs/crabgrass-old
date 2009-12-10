require File.dirname(__FILE__) + '/../../test_helper'
require 'me/search_controller'

# Re-raise errors caught by the controller.
class Me::SearchController; def rescue_action(e) raise e end; end

class MeSearchControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :page_terms

  def setup
    @controller = Me::SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    return unless sphinx_working?

    login_as :blue

    get :index
    assert_response :success
 end

  def test_mysql_pagination
    return if sphinx_working?

    login_as :blue
    get :index
    assert assigns(:pages)
    assert assigns(:pages).total_pages
  end

  def test_text_search
    return unless sphinx_working?

    login_as :blue

    get :index, :path => ["text", "test"]
    assert_response :success
    assert assigns(:pages).any?, "should find a page"
    assert assigns(:pages).total_pages
    assert_not_nil assigns(:pages)[0].flag[:excerpt], "should generate an excerpt"
  end

  def test_text_search_and_sort
    return unless sphinx_working?

    login_as :blue

    get :index, :path => ["text", "test", "ascending", "owner_name"]
    assert_response :success
    assert assigns(:pages).any?, "should find a page"
    assert_not_nil assigns(:pages)[0].flag[:excerpt], "should generate an excerpt"
  end

end
