require File.dirname(__FILE__) + '/../test_helper'
require 'me_controller'

# Re-raise errors caught by the controller.
class MeController; def rescue_action(e) raise e end; end

class MeControllerTest < Test::Unit::TestCase

  fixtures :users, :languages, :sites

  def setup
    @controller = MeController.new
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
#    assert_template 'search'
    assert assigns(:pages).length > 0, "search should find some pages"

    search_opts = {:text => "", :type => "", :person => "", :group => "", :month => "", :year => ""}

    post :search, :search => search_opts
    assert_response :redirect
    assert_redirected_to me_url(:action => 'search') + @controller.parse_filter_path(search_opts)

    search_opts[:text] = "e"
    post :search, :search => search_opts
    assert_response :redirect
    assert_redirected_to 'me/search/text/e'
  end
=end

  def test_edit
    user = User.make
    login_as(user)
    get :edit
    assert_response :success
#    assert_template 'edit'

    # test that things which should change, do
    post :edit, :user => {:login => 'new_login'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'new_login', User.find(user.id).login, "login for quentin should have changed"

    post :edit, :user => {:display_name => 'new_display'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'new_display', User.find(user.id).display_name, "display_name for quentin should have changed"

    post :edit, :user => {:email => 'email@example.com'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'email@example.com', User.find(user.id).email, "email for quentin should have changed"

    post :edit, :user => {:language => "de_DE"}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal "de_DE", User.find(user.id).language, "language for quentin should have changed"

    post :edit, :user => {:time_zone => 'Samoa'}
    assert_response :redirect
    assert_redirected_to :action => :edit
    assert_equal 'Samoa', User.find(user.id).time_zone, "time zone for quentin should have changed"

    # test that things which should not change, don't
    cp = user.crypted_password
    post :edit, :user => {:crypted_password => ""}
    assert_equal cp, User.find(user.id).crypted_password, "hackers should not be able to reset password"
  end

  # tests if deleting an avatar works
  def test_delete_avatar
    #Todo: Write this test
    # for this test we need a fixture user with an avatar already
  end

end
