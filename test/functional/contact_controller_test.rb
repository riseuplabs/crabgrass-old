require File.dirname(__FILE__) + '/../test_helper'
require 'contact_controller'

# Re-raise errors caught by the controller.
class ContactController; def rescue_action(e) raise e end; end

class ContactControllerTest < Test::Unit::TestCase
  fixtures :users, :contacts
  
  def setup
    @controller = ContactController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_add
    login_as :quentin
    get :add, :id => users(:iguana).login
    assert_response :success 
    
    assert_difference 'Page.count', 2, "should have created a contact request page and discussion page" do
      post :add, :id => users(:iguana).login, :message => ''
    end
  end
  
  def test_remove
    login_as :blue
    get :remove, :id => users(:orange).login
    assert_response :success
    
    assert_no_difference 'users(:blue).contacts.count' do
      post :remove, :id => users(:orange).login, :cancel => true
      assert_response :redirect
      assert_redirected_to @controller.url_for_user(users(:orange))
    end
    
    assert_difference 'users(:blue).contacts.count', -1 do
      post :remove, :id => users(:orange).login
      assert_response :redirect
    end
  end
end
