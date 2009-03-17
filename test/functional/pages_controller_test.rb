require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'
require 'set'

# Re-raise errors caught by the controller.
class PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags

  @@private = AssetExtension::Storage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = AssetExtension::Storage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @request.host = Site.default.domain
    @response   = ActionController::TestResponse.new
    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end

  def test_login_required
    [:tag, :create_wiki, :notify, :access, :participation, :history, :update_public, :move, 
     :remove_from_my_pages, :add_to_my_pages, :make_resolved, :make_unresolved, :add_star,
     :remove_star, :destroy].each do |action|
      assert_requires_login do |c|
        c.get action, :id => pages(:hello).id
      end
    end
  end
  
  def test_create
    login_as :quentin
    get :create
    assert_response :success
#    assert_template 'create'
  end

  def test_create_wiki
    login_as :red
    assert_no_difference 'Page.count', "invalid group should not create a new wiki" do
      post :create_wiki, :name => "new wiki", :group => "nonexistant-group"
    end

    assert_no_difference 'Page.count', "not member of group should not create a new wiki" do
      post :create_wiki, :name => "new wiki", :group => groups(:true_levellers).name
    end

    assert_difference 'Page.count', 1, "should create a new wiki" do
      post :create_wiki, :name => "new wiki", :group => groups(:rainbow).name
    end
  end

  def test_create_assigns_primary_group
    login_as :blue

    assert_difference 'Page.count', 1, "should create a new wiki" do
      post :create_wiki, :name => "new wiki in the private group", :group => groups(:private_group).name
    end
    assert_equal groups(:private_group), Page.find(:all).last.group
  end

end
