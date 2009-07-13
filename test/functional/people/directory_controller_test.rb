require File.dirname(__FILE__) + '/../../test_helper'

class People::DirectoryControllerTest < ActionController::TestCase
  fixtures :users

  def setup
  end

  def test_show
    login_as :quentin
    %w(friends peers directory).each do |action|
      get :show, :id => action
      assert_response :success
      assert_not_nil assigns(:users)
    end
  end
end

