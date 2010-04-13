require File.dirname(__FILE__) + '/../test_helper'
require 'avatars_controller'

# Re-raise errors caught by the controller.
class AvatarsController; def rescue_action(e) raise e end; end

class AvatarsControllerTest < Test::Unit::TestCase
  fixtures :avatars, :users

  def setup
    @controller = AvatarsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    #    post :create
    user = User.find(1)
    login_as user
    post :create, :user_id => user.id, :redirect => '/me'
    assert_equal 'no image uploaded', flash[:error]

    avatar_image = fixture_file_upload('/files/bee.jpg','image/jpg')
    post :create, :user_id => user.id, :image => {:image_file => avatar_image}, :redirect => '/me' 
    assert_equal I18n.t(:avatar_image_upload_success), flash[:message]
    puts @response
  end

end
