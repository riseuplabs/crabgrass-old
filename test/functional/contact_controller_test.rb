require File.dirname(__FILE__) + '/../test_helper'
require 'contact_controller'

# Re-raise errors caught by the controller.
class ContactController; def rescue_action(e) raise e end; end

class ContactControllerTest < Test::Unit::TestCase
  fixtures :users, :relationships, :sites

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

    count = "Friendship.count :conditions => 'user_id = #{users(:blue).id}'"

    assert_no_difference count do
      get :remove, :id => users(:orange).login
    end

    assert_no_difference count do
      post :remove, :id => users(:orange).login, :cancel => true
    end

    assert_difference count, -1 do
      post :remove, :id => users(:orange).login, :remove => true
    end
  end
end
