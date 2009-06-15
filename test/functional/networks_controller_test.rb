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

=begin
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
=end
  def test_create
    login_as :blue
    get :new
    assert_response :success, "should be able to create new network"
    assert_select "form#createform[method=post][action=?]", networks_url(:action=>:create, :only_path => true)

    assert_difference 'groups(:animals).networks.count',1,"animals group should be part of network" do
      create_network_for_animals
    end
  end

  def test_failed_create
    login_as :red
    get :new
    assert_response :success
    assert_no_difference 'groups(:animals).networks.count',"should not be allowed to add animals group to new network" do
      create_network_for_animals
    end
  end

  protected

  def create_network_for_animals
    assert_difference 'Network.count', 1, "new network should be created" do
      post :create,
        :group => {:name => 'testnet'},
        :group_id => groups(:animals).id
      assert_response :redirect, "redirect to edit on creation of new network"
      assert_redirected_to :controller => :networks, :action=>'edit', :id=>'testnet'
    end
  end
end

