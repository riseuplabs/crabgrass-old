require File.dirname(__FILE__) + '/../../test_helper'

class People::DirectoryControllerTest < ActionController::TestCase
  fixtures :users, :relationships

  def setup
  end

  def test_show
    login_as :quentin
    %w(friends peers browse recent).each do |action|
      get :show, :id => action
      assert_response :success
      assert_not_nil assigns(:users)
    end

    get :show, :id => :foo
    assert_permission_denied
  end

  def test_index
    login_as :blue
    get :index
    assert_redirected_to(:action => 'show', :id => :friends)

    login_as :quentin
    get :index
    assert_redirected_to(:action => 'show', :id => :browse)
  end

end

