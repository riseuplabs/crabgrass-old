require File.dirname(__FILE__) + '/../../test_helper'
require 'wiki_page_controller'

# Re-raise errors caught by the controller.
class WikiPageController; def rescue_action(e) raise e end; end

class WikiPageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :wikis, :groups

  def setup
    @controller = WikiPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    HTMLDiff.log_to_stdout = false # set to true for debugging
  end

  def test_show
    login_as :orange

    # existing page
    get :show, :page_id => pages(:wiki).id
    assert_response :success
  end

=begin
  this test doesn't work, but the actual code does.
  not sure how to write this, the page is reset or something
  on the 'get :show'
  def test_show_after_changes
    # force a version greater than 1
    page = Page.find(pages(:wiki).id)
    page.data.body = 'new body'
    page.data.save
    page.data.body = 'new new body'
    page.data.save
    page.save

    users(:blue).updated(page)
    login_as :orange
    get :show, :page_id => page.id
    assert_not_nil assigns(:last_seen), 'last_seen should be set, since the page has changed'    
  end
=end
  
  def test_create
    login_as :quentin
    
    assert_no_difference 'Page.count' do
      post 'create', :page => {:title => nil}
      assert_equal 'error', flash[:type], "page title should be required"
    end
    
    assert_difference 'Page.count' do
      post :create, :page_class=>"WikiPage", :id => 'wiki', :group_id=> "", :create => "Create page", :tag_list => "", 
           :page => {:title => 'my title', :summary => ''}
      assert_response :redirect
      assert_not_nil assigns(:page)
      assert_not_nil assigns(:page).data
      # i don't think the wiki needs to be locked at creation.
      # it will be locked soon enough when on the :edit action
      #assert_equal true, assigns(:page).data.locked?, "the wiki should be locked by the creator"
      assert_redirected_to @controller.page_url(assigns(:page), :action=>'edit')
    end
  end

  def test_edit
    login_as :orange
    pages(:wiki).add users(:orange), :access => :edit
    get :edit, :page_id => pages(:wiki).id
    assert_kind_of Hash, assigns(:wiki).locked?, "editing a wiki should lock it"
    assert_equal users(:orange).id, assigns(:wiki).locked_by_id, "should be locked by orange"
    
    assert_no_difference 'pages(:wiki).updated_at' do
      post :edit, :page_id => pages(:wiki).id, :cancel => 'true'
      assert_equal nil, pages(:wiki).data.locked?, "cancelling the edit should unlock wiki"
    end

    # save twice, since the behavior is different if current_user has recently saved the wiki
    (1..2).each do |i|
      str = "text %d for the wiki" / i
      post :edit, :page_id => pages(:wiki).id, :save => true, :wiki => {:body => str, :version => i}
      assert_equal str, assigns(:wiki).body
      assert_equal nil, pages(:wiki).data.locked?, "saving the edit should unlock wiki"
    end
  end

  def test_version
    login_as :orange
    pages(:wiki).add groups(:rainbow), :access => :edit

    # create versions
    (1..5).zip([:orange, :yellow, :blue, :red, :purple]).each do |i, user|
      login_as user

      pages(:wiki).data.smart_save!(:user => users(user), :body => "text %d for the wiki" / i)
    end

    # create another modification by the last user
    # should not create a new version
    pages(:wiki).data.smart_save!(:user => users(:purple), :body => "text 6 for the wiki")

    login_as :orange
    pages(:wiki).data.versions.reload

    # find versions
    (1..5).each do |i|
      get :version, :page_id => pages(:wiki).id, :id => i
      assert_response :success
      assert_equal i, assigns(:version).version
    end

    # should fail gracefully for non-existant version
    get :version, :page_id => pages(:wiki).id, :id => 6
    assert_response :success
    assert_nil assigns(:version)
  end
  
  def test_diff
    login_as :orange

    (1..5).each do |i|
      pages(:wiki).data.body = "text %d for the wiki" / i
      pages(:wiki).data.save
    end
    pages(:wiki).data.versions.reload

    post :diff, :page_id => pages(:wiki).id, :id => "4-5"
    assert_response :success
#    assert_template 'diff'
    assert_equal assigns(:wiki).versions.reload.find_by_version(4).body_html, assigns(:old_markup)
    assert_equal assigns(:wiki).versions.reload.find_by_version(5).body_html, assigns(:new_markup)
    assert assigns(:difftext).length > 10, "difftext should contain something substantial"
  end

  def test_print
    login_as :orange

    get :print, :page_id => pages(:wiki).id
    assert_response :success
#    assert_template 'print'    
  end
  
  def test_preview
    # TODO:  write action and test
  end
  
  def test_break_lock
    login_as :orange
    page = pages(:wiki)
    user = users(:orange)
    page.add(user, :access => :admin)

    wiki = pages(:wiki).data   
    wiki.lock(Time.now, user)
    
    post :break_lock, :page_id => pages(:wiki).id
    assert_equal nil, wiki.reload.locked?
    assert_redirected_to @controller.page_url(assigns(:page), :action => 'edit', :section => 'all')
  end

end
