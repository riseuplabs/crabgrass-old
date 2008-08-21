require File.dirname(__FILE__) + '/../test_helper'
require 'passwords_controller'

# Re-raise errors caught by the controller.
class PasswordsController; def rescue_action(e) raise e end; end

class PasswordsControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = PasswordsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login_required
    [ :edit, :update ].each do |action|
      get action
      assert_response :redirect, "#{action} should redirect to login if user is not logged in"
      assert_redirected_to :controller => 'account', :action => 'login'
    end
  end

  def test_new
    get :new
    assert_response :success
#    assert_template 'new'
  end

  def test_create
    post :create, :email => 'bad@email.gov'
    assert_response :success
#    assert_template 'new'
  
    post :create, :email => users(:blue).email
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_edit
    secret_code = users(:blue).forgot_password
    post :edit, :id => secret_code
    
    # what should happen now?
    # assert_redirected_to ...
  end
  
  def test_update
    # TODO: write these tests and the rest of the controller
  end

end
