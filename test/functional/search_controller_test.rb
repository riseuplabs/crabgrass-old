require File.dirname(__FILE__) + '/../test_helper'

class SearchControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :page_terms

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

    # text "test" inside listings should be surrounded with <span class="search-excerpt"></span>
    assert_select "article span.search-excerpt", "test", "should highlight exceprts in markup"
  end

end


=begin
  TODO: make it work
  def test_search
    login_as :quentin

    get :search
    assert_response :success
#    assert_template 'search'
    assert assigns(:pages).length > 0, "search should find some pages"

    search_opts = {:text => "", :type => "", :person => "", :group => "", :month => "", :year => ""}

    post :search, :search => search_opts
    assert_response :redirect
    assert_redirected_to me_url(:action => 'search') + @controller.parse_filter_path(search_opts)

    search_opts[:text] = "e"
    post :search, :search => search_opts
    assert_response :redirect
    assert_redirected_to 'me/search/text/e'
=end
