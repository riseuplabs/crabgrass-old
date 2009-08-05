require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  def test_index
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
    @user = users(:red)
    # test change password and display name
    post :update, :user => {:login => @user.login, :display_name => 'RedRoot!', :email => @user.email, :password => 'changedpassword', :password_confirmation => 'changedpassword' }
    assert_redirected :action => 'show'
    assert_equal assigns(:user).login, 'RedRoot!'
  end

    # Reject a page by setting flow=FLOW[:deleted], the page will now be 'deleted'(hidden)
  def trash
    page = Page.find params[:id]
    page.update_attribute(:flow, FLOW[:deleted])
    redirect_to :action => 'index', :view => params[:view]
  end

  # undelete a page by setting setting flow=nil, the page will now be 'undeleted'(unhidden)
  def undelete
    page = Page.find params[:id]
    page.update_attribute(:flow, nil)
    redirect_to :action => 'index', :view => params[:view]
  end

  # set page.public = true for a page which has its flag public_requested = true
  def update_public
    page = Page.find params[:id]
    page.update_attributes({:public => params[:public], :public_requested => false})
    redirect_to :action => 'index', :view => params[:view]
  end

# set page.public = false
  def remove_public
    page = Page.find params[:id]
    page.update_attributes({:public => false, :public_requested => true})
    redirect_to :action => 'index', :view => params[:view]
  end


  def test_approve

  end

  def test_trash
    login_as :blue
    get :trash, :id => @page.id
    assert_response :success
    assert assigns(:user)
  end

  def test_delete
    login_as :blue
    post :create, :user => {:login => 'testuser', :display_name => 'TestUser', :email => 'testuser@testsite.com', :password => 'testpassword', :password_confirmation => 'testpassword' }
    assert_redirected :action => 'show'
    assert_equal assigns(:user).login, 'testuser'

    # todo: assert failing create test
  end

  def test_update_public
    login_as :blue
    @user = users(:red)
    get :edit, :user_id => @user.id
    assert_response :success
    assert_equal @user.login, assigns(:user).login
  end

  def test_remove_public
    login_as :blue
    @user = users(:red)
    get :destroy, :id => @user.login
    assert_redirected :action => 'index'
    assert_nil User.find_by_login(@user.login)
  end

end
