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

    assert !users(:quentin).friend_of?(users(:iguana))
    assert users(:iguana).profiles.visible_by(users(:quentin)).may_request_contact?

    get :add, :id => users(:iguana).login
    assert_response :success 
    
    assert_difference 'RequestToFriend.count' do
      post :add, :id => users(:iguana).login, :message => '', :send => true
    end
  end
  
  def test_remove
    login_as :blue
    get :remove, :id => users(:orange).login
    assert_response :success
    
    assert_no_difference 'users(:blue).contacts.count' do
      post :remove, :id => users(:orange).login, :cancel => true
    end
    
    assert_difference 'users(:blue).contacts.count', -1 do
      post :remove, :id => users(:orange).login, :remove => true
    end
  end
end
