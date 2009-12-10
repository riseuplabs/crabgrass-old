require File.dirname(__FILE__) + '/../../../../test/test_helper'

class RateManyPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    @request.host = "localhost"
  end

  def test_all
    login_as :orange

    assert_no_difference 'Page.count' do
      get :create, :id => RateManyPage.param_id
      assert_response :success
    end

    page_id = nil
    assert_difference 'RateManyPage.count' do
      post :create, :id => RateManyPage.param_id, :page => {:title => 'test title'}
      page_id = assigns(:page).id
      assert_response :redirect
    end
    page = Page.find(page_id)

    get :show, :page_id => page_id
    assert_response :success

    assert_difference 'page.data.possibles.count' do
      post :add_possible, :page_id => page_id, :possible => {:name => "new option", :description => ""}
    end
    assert_not_nil assigns(:possible)

    assert_difference 'page.data.possibles.count', -1 do
      post :destroy_possible, :page_id => page_id, :possible => assigns(:possible).id
    end

    post :add_possible, :page_id => page_id, :possible => {:name => "new option", :description => ""}
    id = assigns(:possible).id
    post :vote_one, :page_id => page_id, :id => id, :value => "2"
    assert_equal 2, Possible.find(id).votes.find(:all).find { |p| p.user = users(:orange) }.value
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :page => {:title => "dupe", :summary => ""}, :id => RateManyPage.param_id
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new poll
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

  # TODO: tests for vote, clear votes, sort
end
