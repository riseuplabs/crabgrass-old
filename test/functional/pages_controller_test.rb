require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'
require 'pages_helper'

class PagesControllerTest < ActionController::TestCase
  fixtures :users, :pages, :user_participations

  def test_new
    login_as :quentin
    get :new
    assert_response :success
  end

  def test_new_for_group
    login_as :blue
    get :new, :group_id => 1
    assert_response :success
    assert_not_nil assigns(:group)
  end

  def test_my_work
    login_as :blue
    get :my_work
    assert_response :success
    assert assigns(:pages).length > 0
    [:work, :watched, :editor, :owner, :unread].each do |view|
      get :my_work, :view => view
      assert_response :success
    end
  end

  def test_all_pages
    login_as :blue
    get :all
    assert_response :success
    assert assigns(:pages).length > 0
    [:public, :networks, :groups].each do |view|
      get :my_work, :view => view
      assert_response :success
    end
  end

  def test_index_to_all
    login_as :blue
    get :index, :path => 'type/discussion'
    assert_response :success
    assert_template "all"

    get :index, :path => ['ascending', 'title']
    assert_response :success
    assert assigns(:pages).length > 0

    get :index, :path => ['unread', 4]
    assert_response :success
    assert assigns(:pages).length > 0
  end

  def test_index_to_my_work
    login_as :blue
    get :index
    assert_response :redirect
    assert_redirected_to :action => :my_work
  end

  def test_index_without_logging_in
    get :index
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login, :redirect => "/me/pages"
  end

end

# TODO: transfer the old inbox controller tests that have not been transfered yet.
#
#class InboxControllerTest < ActionController::TestCase
#  fixtures :users, :user_participations, :groups, :group_participations, :pages, :sites
#
#  def test_rss
#    login_as :blue
#    get :list, :path => ['rss']
#    assert_response :success
#    assert @response.headers['type'] =~ /rss/
#  end
#
#  def test_remove_by_posting_to_index
#    login_as :blue
#    get :index
#    assert assigns(:pages).length > 0
#
#    removed_page_id = assigns(:pages).first.id
#    puts assigns(:pages).clear
#    post :update, :page_checked => { removed_page_id.to_s => "checked"}, :remove => true
#    assert_nil assigns(:pages).find {|p| p.id == removed_page_id },
#               "page #{removed_page_id} shouldn't be in the inbox anymore"
#  end
#
#
#  def test_search
#    login_as :blue
#    @user = users(:blue)
#    assert @user, 'the user should exist'
#    assert @user.groups, 'the user should have at least one group for this test'
#    assert @user.contacts, 'the user should have at least one contact for this test'
#    # test some various calls on the search methods, that could come from the search_controller by post
#
#    #TODO: This test should also test if the right pages come back as result. This test only checks if posting a search leads into an error so far.
#
#
#    # test with empty parameters (=> showing all pages}
#    post :search, :search => { :text => "", :type => "", :page_state => "", :person => "", :group => "" }, :commit => "Search"
#    # perform a text search
#    post :search, :search => { :text => "baum", :type => "", :page_state => "", :person => "", :group => "" }, :commit => "Search"
#
#    # perform a search for user and group
#    post :search, :search => { :text => "", :type => "", :page_state => "", :person => @user.friends.first.login, :group => @user.groups.first.name }, :commit => "Search"
#
#    # testing all pages with all page states
#    #todo: this should be dynamically loaded from the sites available pages
#    page_types = Site.first.available_page_types.collect do |page_class_string|
#      page_class = Page.class_name_to_class(page_class_string)
#      page_group = page_class.class_group.first
#    end
#
#    #todo: this also should maybe loaded dynamically
#    page_states = ["unread","pending","starred"]
#    page_types.each do |type|
#      page_states.each do |state|
#            post :search, :search => { :text => "", :type => type, :page_state => state, :person => "", :group => ""}, :commit => "Search"
#      end
#    end
#  end
#
#end
