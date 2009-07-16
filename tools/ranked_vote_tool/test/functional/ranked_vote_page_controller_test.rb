require File.dirname(__FILE__) + '/../../../../test/test_helper'

class RankedVotePageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    @request.host = "localhost"
    login_as :orange
    get :create, :id => RankedVotePage.param_id
  end

  def test_create_show_add_and_show
    assert_no_difference 'Page.count' do
      get :create, :id => RankedVotePage.param_id
      assert_response :success
#      assert_template 'base_page/create'
    end

    assert_difference 'RankedVotePage.count' do
      post :create, :id => RankedVotePage.param_id, :page => {:title => 'test title'}
      assert_response :redirect
    end

    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :redirect
    assert_redirected_to @controller.page_url(assigns(:page), :action => 'edit') # redirect to edit since no possibles

    assert_difference 'p.data.possibles.count' do
      post :add_possible, :page_id => p.id, :possible => {:name => "new option", :description => ""}
    end

    get :show, :page_id => p.id
    assert_response :success
#    assert_template 'ranked_vote_page/show'
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :page => {:title => "dupe", :summary => ""}, :id => RankedVotePage.param_id
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new ranked vote
      assert !data_ids.include?(page.data.id)
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      data_ids << page.data.id
      page_ids << page.id
      page_urls << page.name_url
    end
  end

  def test_show_new
    login_as :blue
    post 'create', :page => {:title => "vote"}, :id => RankedVotePage.param_id
    get :edit, :page_id => assigns(:page).id
    assert_response :success
  end

  # TODO: tests for sort, update_possible, edit_possible, destroy_possible,
end
