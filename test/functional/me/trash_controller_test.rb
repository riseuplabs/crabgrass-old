require File.dirname(__FILE__) + '/../../test_helper'

class Me::TrashControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :tasks, :task_participations, :task_lists, :page_terms

  def teardown
    # we use transactional fixtures for everything except page terms
    # page_terms is a different ttable type (MyISAM) which doesn't support transactions
    reset_page_terms_from_fixtures
  end

  def test_index_and_undelete
    login_as :blue

    get :index
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page"
    id = assigns(:pages).first.id
    assert_equal id, 207, "expecting page 207 as deleted page for blue"
    post :update, :pages=>["207"], :path=>[], :undelete=>"Undelete"
    assert_redirected_to(:action => 'search')
    get :index
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page after undeleting"
  end

  def test_remove
    login_as :blue

    get :index
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page"
    id = assigns(:pages).first.id
    assert_equal id, 207, "expecting page 207 as deleted page for blue"
    assert_difference 'Page.count', -1, "removing page from trash destroys it" do
      post :update, :pages=>["207"], :path=>[], :remove=>"Remove"
      assert_response :redirect
    end
    get :index
    assert_response :success
    assert assigns(:pages).empty?, "should not find a deleted page after removing"
  end

  def test_text_search
    return unless sphinx_working?(:test_text_search)
    login_as :blue

    get :index, :path => ["text", "test"]
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page by contained text"
  end

  def test_text_search_and_sort
    return unless sphinx_working?(:test_text_search_and_sort)
    login_as :blue

    get :index, :path => ["text", "test", "ascending", "owner_name"]
    assert_response :success
    assert assigns(:pages).any?, "should find a deleted page with group sorting."
  end

  def test_search
    return unless sphinx_working?(:test_text_search_and_sort)
    login_as :blue

    get :search, :search => 'foo'
    assert_response :success

    post :search, :search => 'foo'
    assert_redirected_to(:controller => '/me/trash')
  end

  def test_update_no_path  # this just gets the coverage to 100% :-/
    login_as :blue
    post :update, :pages=>["207"], :remove=>"Remove"
    assert_response :redirect
  end

end
