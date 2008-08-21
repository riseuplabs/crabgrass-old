require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

# Re-raise errors caught by the controller.
class ProfileController; def rescue_action(e) raise e end; end

class ProfileControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_show
    login_as :quentin
    user = users(:quentin)
    get :show, :id => user.profiles.public.id
    assert_response :success
#    assert_template 'show'
  end
  
  def test_edit
    login_as :quentin
    user = users(:quentin)
    get :edit, :id => user.profiles.public.id
    assert_response :success
#    assert_template 'edit'
  end
end
