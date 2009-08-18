require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DiscussionPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @request.host = "localhost"
  end

  def test_show
    page = DiscussionPage.find :first, :conditions => {:public => true}
    get :show, :page_id => page.id
    assert_response :success
  end

  def test_create_and_show
    login_as :orange

    assert_no_difference 'Page.count' do
      get :create, :id => DiscussionPage.param_id
      assert_response :success
    end

    assert_difference 'DiscussionPage.count' do
      post :create, :id => DiscussionPage.param_id, :page => { :title => 'test discussion', :tag_list => 'humma, yumma' }
    end
    page = assigns(:page)
    assert page
    assert page.tag_list.include?('humma')
    assert Page.find(page.id).tag_list.include?('humma')
    assert_response :redirect

    get :show
    assert_response :success
  end

  def test_create_same_name
    login_as :gerrard

    page_ids, page_urls = [],[]
    3.times do
      post 'create', :id => DiscussionPage.param_id, :page => {:title => "dupe", :summary => ""}
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      page_ids << page.id
      page_urls << page.name_url
    end
  end

end
