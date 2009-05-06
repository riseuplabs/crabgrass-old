require File.dirname(__FILE__) + '/../test_helper'
require 'networks_controller'

# Re-raise errors caught by the controller.
class NetworksController; def rescue_action(e) raise e end; end

class NetworksControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :groups, :user_participations, :group_participations, :discussions, :memberships, :posts, :activities
  def setup
    @controller = NetworksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    login_as :blue
    get :index
    assert_response :redirect
    assert_redirected_to :action => :list
  end

  def test_list
    login_as :blue
    get :list
    assert_response :success
  end

  def test_create
    login_as :blue
    get :create
    assert_response :success

    assert_difference 'Network.count', 1 do
      post :create,
        :group => {:name => 'testnet'},
        :group_id => groups(:animals).id
      assert_response :redirect
      assert_redirected_to :controller => :dispatch, "_context"=>"testnet"
    end
  end

  def test_failed_create
    login_as :red
    get :create
    assert_response :success

    assert_no_difference 'Network.count' do
      post :create,
        :group => {:name => 'testnet2'},
        :group_id => groups(:animals).id
      assert_response :redirect
      assert_redirected_to :controller => :account, :action => :login
    end
  end
end
