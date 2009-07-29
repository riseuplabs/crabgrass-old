require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships, :pages

  def setup
    enable_site_testing("moderation")
  end

  def test_index_view
    login_as :blue
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
    # run through all the different possible views
    ['pending', 'vetted', 'deleted', 'new', 'public requested', 'public', 'all'].each do |view|
      get :index, :view => view
      assert_response :success
      assert_not_nil assigns(:pages)
    end
  end

  def test_update
    login_as :blue
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

  def test_update_restricted_to_moderation
    login_as :blue
    page = pages(:video1) #blue does not have access to video1
    post :update, :id => page.id, :page => {:title => "pwned"}
    assert_response :redirect
    assert_redirected_to({:controller => 'account', :action => 'login'},
      "blue may moderate but not change the page.")
  end

  def test_update_restricted_to_moderators
    login_as :red
    page = pages(:video1) #blue does not have access to video1
    post :update, :id => page.id, :page => {:vetted => true}
    assert_response :redirect
    assert_redirected_to({:controller => 'account', :action => 'login'},
      "red may not moderate the page.")
  end
end
