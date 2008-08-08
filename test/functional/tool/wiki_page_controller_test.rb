require File.dirname(__FILE__) + '/../../test_helper'
require 'wiki_page_controller'

# Re-raise errors caught by the controller.
class WikiPageController; def rescue_action(e) raise e end; end

class WikiPageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations, :wikis

  def setup
    @controller = WikiPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    login_as :orange

    # existing page
    get :show, :page_id => pages(:wiki).id
    assert_template 'show', "should render wiki page view"
   
    # new page
=begin
    page = WikiPage.create :title => 'new wiki', :public => false
    @controller.stubs(:login_or_public_page_required).returns(true)

    get :show, :page_id => page.id
    assert_redirected_to 'edit'
=end
  end
  
  def test_create
    login_as :quentin
    assert_difference 'Page.count' do
      post :create, :page_class=>"WikiPage", :id => 'wiki', :group_id=> "", :create => "Create page", :tag_list => "", 
           :page => {:title => 'my title', :summary => ''}
      assert_response :redirect
      assert_not_nil assigns(:page)
      assert_equal true, assigns(:wiki).locked?, "the wiki should be locked by the creator"
      assert_redirected_to @controller.page_url(assigns(:page), :action=>'edit')
    end
  end

  def test_edit
    login_as :orange
    get :edit, :page_id => pages(:wiki).id
    assert_equal true, assigns(:wiki).locked?, "editing a wiki should lock it"
    assert_equal users(:orange).id, assigns(:wiki).locked_by.id, "should be locked by orange"
    
    assert_no_difference 'pages(:wiki).updated_at' do
      post :edit, :page_id => pages(:wiki).id, :cancel => 'true'
      assert_equal nil, pages(:wiki).data.locked?, "cancelling the edit should unlock wiki"
    end

    # save twice, since the behavior is different if current_user has recently saved the wiki
    (1..2).each do |i|
      str = "text %d for the wiki" / i
      post :edit, :page_id => pages(:wiki).id, :wiki => {:body => str, :version => i}
      assert_equal str, assigns(:wiki).body
      assert_equal nil, pages(:wiki).data.locked?, "saving the edit should unlock wiki"
    end
  end

  def test_version
    login_as :orange

    (1..5).each do |i|
      pages(:wiki).data.body = "text %d for the wiki" / i
      pages(:wiki).data.save
    end
    pages(:wiki).data.versions.reload

    # should find any version in 2..6
    (2..6).each do |i|
      get :version, :page_id => pages(:wiki).id, :id => i
      assert_template 'version'
      assert_equal i, assigns(:version).version
    end
    
    # should fail gracefully for non-existant version
    get :version, :page_id => pages(:wiki).id, :id => 7
    assert_template 'version'
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
    assert_template 'diff'
    assert_equal assigns(:wiki).versions.reload.find_by_version(4).body_html, assigns(:old_markup)
    assert_equal assigns(:wiki).versions.reload.find_by_version(5).body_html, assigns(:new_markup)
    assert_not_nil assigns(:difftext)
  end

  def test_print
    login_as :orange

    get :print, :page_id => pages(:wiki).id
    assert_template 'print'    
  end
  
  def test_preview
    # TODO:  write action and test
  end
  
  def test_break_lock
    login_as :orange

    pages(:wiki).data.lock(Time.now, users(:orange))
    
    get :break_lock, :page_id => pages(:wiki).id
    assert_equal nil, pages(:wiki).data.reload.locked?
    assert_redirected_to @controller.page_url(assigns(:page), :action => 'show')
  end

end
