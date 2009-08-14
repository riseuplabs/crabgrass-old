require File.dirname(__FILE__) + '/../../../../test/test_helper'

class MessagePageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @request.host = "localhost"
  end

  def test_create_and_show
    login_as :orange

    assert_no_difference 'Page.count' do
      get :create, :id => MessagePage.param_id
      assert_response :success
#      assert_template 'message_page/create'
    end

    assert_difference 'MessagePage.count' do
      post :create, :id => MessagePage.param_id, :title => 'test title', :to => 'red', :message => 'hey d00d'
      assert_response :redirect
    end

    p = Page.find(:all)[-1] # most recently created page (?)
    assert p.users.include?(User.find_by_login('red')), "MessagePage should be shared with red."
    assert p.users.include?(User.find_by_login('orange')), "MessagePage should be shared with orange."
    assert !p.user_participations.map(&:inbox).include?(false), "MessagePage should be sent to inbox."

    get :show, :page_id => p.id
    assert_response :success
#    assert_template 'message_page/show'
  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :id => MessagePage.param_id, :title => 'dupe', :to => 'red', :message => 'hi again'
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new discussion
      assert !data_ids.include?(page.discussion.id)
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      data_ids << page.discussion.id
      page_ids << page.id
      page_urls << page.name_url
    end
  end
end
