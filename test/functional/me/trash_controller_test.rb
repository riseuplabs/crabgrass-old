require File.dirname(__FILE__) + '/../../test_helper'
require 'me/trash_controller'

# Re-raise errors caught by the controller.
class Me::TrashController; def rescue_action(e) raise e end; end

class MeTrashControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :tasks, :task_participations, :task_lists, :page_terms

  def setup
    @controller = Me::TrashController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_01_index_and_undelete
    login_as :blue

    get :index
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page"
    id = assigns(:pages).first.id
    assert_equal id, 207, "expecting page 207 as deleted page for blue"
    post :update, :page_checked=>{"207"=>"checked"}, :path=>[], :undelete=>"Undelete"
    assert_response :redirect
    get :index
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page after undeleting"
 end
 
  def test_10_remove
    # this one should not run before index_and_undelete - otherwise the Page will be gone.
    login_as :blue

    get :index
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page"
    id = assigns(:pages).first.id
    assert_equal id, 207, "expecting page 207 as deleted page for blue"
    assert_difference 'Page.count', -1, "removing page from trash destroys it" do
      post :update, :page_checked=>{"207"=>"checked"}, :path=>[], :remove=>"Remove"
      assert_response :redirect
    end
    get :index
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page after undeleting"
 end

 def test_02_text_search
    return unless sphinx_working?(:test_text_search)
    login_as :blue

    get :index, :path => ["text", "test"]
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page"
  end

 def test_03_text_search_and_sort
    return unless sphinx_working?(:test_text_search_and_sort)
    login_as :blue

    get :index, :path => ["text", "test", "ascending", "group_name"]
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page"
  end

end
