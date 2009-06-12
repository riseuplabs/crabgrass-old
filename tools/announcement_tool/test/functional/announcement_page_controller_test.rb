require File.dirname(__FILE__) + '/../../../../test/test_helper'

class AnnouncementPageControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites

  def test_show
    login_as :gerrard

    defaults = {:title => 'untitled page', :public => false}
    page = AnnouncementPage.create({:title => "announcement1", :user => users(:gerrard), :data => Wiki.new(:body => "hi world")})

    get :show, :page_id => page.id

    assert_response :success
    assert_equal "announcement1", assigns(:page).title
    assert_equal "hi world", assigns(:page).data.body
  end

  def test_create
    login_as :gerrard

    get 'create', :id => AnnouncementPage.param_id
    assert_response :success

    post 'create', :id => AnnouncementPage.param_id, :page => {:title => "announcement page", :summary => ""}, :body => "the text"
    page = assigns(:page)

    assert_redirected_to "_page_action" => "show", "_page" => page.name_url
    assert_not_nil page
    assert_equal "announcement page", page.title
    assert_equal "the text", page.data.body
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :id => AnnouncementPage.param_id, :page => {:title => "dupe", :summary => ""}
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new wiki
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
end