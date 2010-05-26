require File.dirname(__FILE__) + '/../test_helper'

class NetworksControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :federatings, :sites


#  def test_check_site_settings
#    enable_site_testing()
#    Site.current.update_attributes!(:has_networks => 0)
#    @current_site = Site.current 
#    get :show, :id => groups(:cnt).to_param
#    assert_response :redirect
#  end

  def test_show
    login_as :blue
    get :show, :id => groups(:fai).to_param
    assert_response :success

    enable_site_testing('site1')
    @current_site=Site.current
    get :show, :id => groups(:cnt).to_param
    assert_response :redirect
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

  def edit
    login_as :blue
    get :edit, :id => groups(:fai).to_param
    assert_equal assigns(:group_navigation), :settings
    assert_response :success
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

  # test for #1988
  def test_network_drop_down
    login_as :penguin
    get :show, :id => groups(:fai).to_param
    assert_response :success
    assert_select 'li#menu_networks' do
      assert_select 'a.entity[title="rainbow+the-cold-colors"]', false,
        "Committees should not show up in the network dropdown menu."
    end
  end

  protected

  def create_network(opts)
    assert_difference 'Network.count', 1, "new network should be created" do
      post :create, :group => {:name => opts[:name]}, :group_id => groups(opts[:group]).id
    end
  end
end

