require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'
require 'set'

# Re-raise errors caught by the controller.
class PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # cases to test:
  # not_logged in
  #  public pages
  #  non-public pages
  # logged in
  #  public pages
  #  non-public pages
  #  pages in your group

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
    assert_template 'create'
  end

  def test_tag
    login_as :red

    # sometime people use commas and sometimes they don't
    # so we want to be able to handle a few different behaviors
    
    # good user
    xhr :post, :tag, :id => pages(:page1).id, :tag_list => "tag1 tag2 tag3"
    assert_equal Set.new(["tag1","tag2","tag3"]), Set.new(pages(:page1).tag_list)
    
    # multiple spaces
    xhr :post, :tag, :id => pages(:page1).id, :tag_list => "tag1a  tag2a       tag3a"
    assert_equal Set.new(["tag1a","tag2a","tag3a"]), Set.new(pages(:page1).reload.tag_list)
    
    # non-space delimiters
    xhr :post, :tag, :id => pages(:page1).id, :tag_list => "tag1b\ttag2b\t\ntag3b\ntag4b\t"
    assert_equal Set.new(["tag1b","tag2b","tag3b","tag4b"]), Set.new(pages(:page1).reload.tag_list)

    # comma and space delimiters
    xhr :post, :tag, :id => pages(:page1).id, :tag_list => "tag1c,  tag2c"
    assert_equal Set.new(["tag1c","tag2c"]), Set.new(pages(:page1).reload.tag_list)
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

  def test_notify
    login_as :red
    get :create
    
    post :notify, :id => pages(:page1).id, :to => users(:blue).login, :message => "check out this page"
    assert UserParticipation.find(:all).find { |up| up.user_id == users(:blue).id and up.page_id == pages(:page1).id and up.notice }

  end
  
  def test_add_access
    page = Page.find(1)
    assert page, 'page should exist'

    user = User.find_by_login('red')
    assert user, 'user should exist'
    assert user.may?(:admin, page), 'user should be able to admin page'
    login = login_as(:red)
    assert_equal login, 8, 'should login as user 8'
 
    group = Group.find_by_name('public_group_everyone_can_see')
    assert group, 'group should exist'
    assert !group.may?(:admin, page), 'public group should not have access to page'

    post 'access', :id => page.id, :add_name => group.name
    assert user.may_pester?(group), 'user should be able to pester pub group'
    page.reload
    assert group.may?(:admin, page), 'public group should have access to page'
    
    group_private = Group.find_by_name('private_group_not_everyone_can_see')   
    assert group, 'private group should exist'
    assert !group_private.may?(:admin, page), 'private group should not have access to page originally'
 
    post 'access', :id => page.id, :add_name => group_private.name
    page.reload
    assert !group_private.may?(:admin, page), 'private group should still not have access to page'

    post 'access', :id => page.id, :add_name => users(:penguin).name
    page.reload
    users(:penguin).reload
# TODO: figure out why this assert fails intermittently
#    assert users(:penguin).may?(:admin, page), 'user penguin should have access to page'
  end
  

  def test_remove_from_my_inbox
    login_as :blue
    get :create  # need this to make @controller.current_user = blue
    user = @controller.current_user
    
    name = 'my new page'
    page = WikiPage.new do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
    end
    page.save
    page.add(user)
    page.save!
    
    assert user.may?(:admin, page), "blue should have access to new wiki"
    
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    assert inbox_pages.find {|p| p.id = page.id}, "new wiki should be in blue's inbox"
    
    post 'remove_from_my_pages', :id => page.id
    page.reload
    
    inbox_pages = Page.find_by_path('', @controller.options_for_inbox)
    assert inbox_pages.find {|p| p.id == page.id} == nil, "new wiki should not be in blue's inbox"
    
    assert user.may?(:admin, page), "blue should still have access to new wiki"
  end
  
  def test_set_title
    login_as(:red)
    post :update_title, :id => 1, :page => {:title => "new title"}, :save => 'Save pressed'
    assert_equal "new title", Page.find(1).title
  end

end
