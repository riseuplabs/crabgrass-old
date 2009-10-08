require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :sites

  def test_non_siteadmin_may_not_create_group
    with_site :unlimited do
      login_as :gerrard
      get :new
      assert_response :redirect
      assert_redirected_to :controller => account, :action => :login
      post :create, :name=>"test-group"
      assert_response :redirect
      assert_redirected_to :controller => account, :action => :login
    end
  end

  def test_siteadmin_may_create_group
    with_site :unlimited do
      login_as :penguin
      get :new
      assert_response :success
      assert_difference 'Group.count' do
       post :create, :name=>"test-group"
      end
      assert_response :redirect
      assert_redirected_to :action => :edit, :id => "test-group"
    end
  end

end
