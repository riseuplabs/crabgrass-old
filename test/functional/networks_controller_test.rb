require File.dirname(__FILE__) + '/../test_helper'
require 'networks_controller'

# Re-raise errors caught by the controller.
class NetworksController; def rescue_action(e) raise e end; end

class NetworksControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :memberships, :federatings

  def setup
    @controller = NetworksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    login_as :blue
    get :show, :id => groups(:fai).to_param
    assert_response :success
  end

  def test_create
    login_as :blue
    get :new
    assert_response :success, "should be able to create new network"
    assert_select "form#createform[method=post][action=?]", networks_url(:action=>:create, :only_path => true)

    assert_difference 'groups(:animals).networks.count',1,"animals group should be part of network" do
      create_network(:name => 'testnet', :group => :animals)
      assert_response :redirect, "redirect to edit on creation of new network"
      assert_redirected_to :controller => :networks, :action=>'edit', :id=>'testnet'
    end
  end

  def create_with_no_groups
    login_as :blue
    post :create, :group => {:name => 'baby-bat'}
    network = Network.find(:last)
    assert 'baby-bat', network.name
    assert network.users.any?
    assert 'blue', network.users.first.name
  end

  def test_failed_create
    login_as :red
    get :new
    assert_response :success
    assert_no_difference 'groups(:animals).networks.count',"should not be allowed to add animals group to new network" do
      create_network(:name => 'testnetwork', :group => :animals)
    end
  end

  protected

  def create_network(opts)
    assert_difference 'Network.count', 1, "new network should be created" do
      post :create, :group => {:name => opts[:name]}, :group_id => groups(opts[:group]).id
    end
  end
end

