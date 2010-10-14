require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  fixtures :pages

  def setup
    setup_site_with_moderation
  end

  def test_index_view
    with_site "moderation" do
      login_as @mod
      get :index
      assert_response :success
      assert_not_nil assigns(:flagged)
    # run through all the different possible views
      ['vetted', 'deleted', 'new', 'public requested', 'public', 'all'].each do |view|
        get :index, :view => view
        assert_response :success
        assert_not_nil assigns(:flagged), "no pages for #{view}"
      end
    end
  end

  def test_update
    with_site "moderation" do
      login_as @mod
      page = pages(:video1) #blue does not have access to video1
      # test change moderation flags should be possible never the less.
      [:public, :vetted].each do |para|
        post :update, :id => page.id, :page => {para => true}
        assert_response :redirect
        assert_redirected_to :action => 'index'
        assert page.reload.send("#{para.to_s}?")
      end
      [:public, :vetted].each do |para|
        post :update, :id => page.id, :page => {para => false}
        assert_response :redirect
        assert_redirected_to :action => 'index'
        assert !page.reload.send("#{para.to_s}?")
      end
    end
  end

  def test_update_restricted_to_moderation
    with_site "moderation" do
      login_as @mod
      page = pages(:video1) #blue does not have access to video1
      old_title = page.title
      post :update, :id => page.id, :page => {:title => "pwned"}
      assert_equal old_title, page.reload.title,
        "Moderator should not be able to change site content."
    end
  end

  def test_update_restricted_to_moderators
    with_site "moderation" do
      user = User.make
      login_as user
      page = pages(:video1) #user does not have access to video1
      assert !page.vetted
      post :update, :id => page.id, :page => {:vetted => true}
      assert !page.vetted,
        "normal user may not moderate the page."
    end
  end

  def test_should_get_update_public
    # TODO: this should only work for pages with public requested
    with_site "moderation" do
      login_as @mod
      get :update_public, :id => Page.first.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert !Page.first.public?
      assert !Page.first.public_requested?
      get :update_public, :id => Page.first.id, :public => true
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert Page.first.public?
      assert !Page.first.public_requested?
    end
  end

  def test_should_get_reject_public
   with_site "moderation" do
      login_as @mod
      get :update_public, :id => Page.first.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert !Page.first.public?
      assert !Page.first.public_requested?
      get :update_public, :id => Page.first.id, :public => false 
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert !Page.first.public?
      assert !Page.first.public_requested?
    end
  end

  def test_should_get_remove_public
    with_site "moderation" do
      login_as @mod
      page=Page.first
      page.update_attributes :public => true, :public_requested => false
      get :remove_public,  :id => page.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
      assert !Page.first.public?
      assert Page.first.public_requested?
    end
  end
end
