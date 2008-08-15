require File.dirname(__FILE__) + '/../../test_helper'
require 'me/base_controller'

# Re-raise errors caught by the controller.
class Me::BaseController; def rescue_action(e) raise e end; end

class BaseControllerTest < Test::Unit::TestCase

  fixtures :users, :languages
  
  def setup
    @controller = Me::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index_not_logged_in
    get :index
    assert_response :redirect, "shouldn't reach index if not logged in"
    assert_redirected_to({:controller => 'account', :action => 'login'}, "should redirect to account/login")
  end
  
  def test_index
    login_as :quentin
    get :index
    assert_response :redirect, "should redirect"
    assert_redirected_to({:controller => 'me/dashboard'}, "should redirect to dashboard")
  end

=begin
  TODO: move to a different test  
  def test_search
    login_as :quentin

    get :search
    assert_response :success
    assert_template 'search'
    assert assigns(:pages).length > 0, "search should find some pages"

    search_opts = {:text => "", :type => "", :person => "", :group => "", :month => "", :year => ""}

    post :search, :search => search_opts
    assert_response :redirect
    assert_redirected_to me_url(:action => 'search') + @controller.build_filter_path(search_opts)

    search_opts[:text] = "e"
    post :search, :search => search_opts
    assert_response :redirect
    assert_redirected_to 'me/search/text/e'
  end
=end

  def test_edit
    login_as(:quentin)
    get :edit
    assert_response :success
    assert_template 'edit'
    
    # test that things which should change, do
    post :edit, :user => {:login => 'new_login'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'new_login', User.find(users(:quentin).id).login, "login for quentin should have changed"
    
    post :edit, :user => {:display_name => 'new_display'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'new_display', User.find(users(:quentin).id).display_name, "display_name for quentin should have changed"
    
    post :edit, :user => {:email => 'email@example.com'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'email@example.com', User.find(users(:quentin).id).email, "email for quentin should have changed"
    
    post :edit, :user => {:language_id => languages(:pt).id}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal languages(:pt), User.find(users(:quentin).id).language, "language for quentin should have changed"
    
    post :edit, :user => {:time_zone => 'Samoa'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'Samoa', User.find(users(:quentin).id).time_zone, "time zone for quentin should have changed"
    
    # test that things which should not change, don't
    post :edit, :user => {:crypted_password => ""}
    assert_equal users(:quentin).crypted_password, User.find(users(:quentin).id).crypted_password, "hackers should not be able to reset password"
    
  end
end
