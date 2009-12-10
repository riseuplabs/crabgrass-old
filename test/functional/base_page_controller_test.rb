require File.dirname(__FILE__) + '/../test_helper'

class BasePageControllerTest < ActionController::TestCase
  fixtures :pages, :groups, :users, :memberships, :group_participations, :user_participations, :sites

  def test_create_without_login
    get :create, :id => WikiPage.param_id
    assert_response :redirect
    assert_redirected_to :controller => 'account', :action => 'login'

    post :create, :id => WikiPage.param_id
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_create_with_login
    login_as :orange

    get :create, :id => WikiPage.param_id
    assert_response :success

    assert_difference 'Page.count' do
      post :create, :id => WikiPage.param_id, :page => { :title => 'test title' }
      assert_response :redirect
    end
  end

  def test_create_duplicate_names
    login_as :blue

    params = ParamHash.new("page_class"=>"WikiPage", "id"=>"wiki", "recipient"=>{"access"=>"admin"}, "page"=>{"title"=>"beet", "tag_list"=>"", "summary"=>"", "owner"=>"blue"}, "recipients"=>{"blue"=>{"access"=>"admin"}}, "create"=>"Create Page »", "recipient_name"=>"")

    assert_difference 'Page.count' do
      assert_difference 'PageTerms.count' do
        assert_difference 'UserParticipation.count' do
          post :create, params
        end
      end
    end

    assert_no_difference 'Page.count', 'no new page' do
      assert_no_difference 'PageTerms.count', 'no new page terms' do
        assert_no_difference 'UserParticipation.count', 'no new user part' do
          post :create, params
        end
      end
    end
  end

  def test_page_creation_access
    login_as :kangaroo
    post :create, {"id"=>DiscussionPage.param_id, "action"=>"create", "page"=>{"title"=>"aaaa"}, "recipients"=>"animals", "controller"=>"discussion_page", "access"=>"view", "create"=>"Create discussion »"}
    page = assigns(:page)
    assert page
    assert users(:kangaroo).may?(:admin,page)
    assert groups(:animals).may?(:view,page)
    assert !groups(:animals).may?(:admin,page), 'group must not have admin access'
  end

end
