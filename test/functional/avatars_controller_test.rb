require File.dirname(__FILE__) + '/../test_helper'

class AvatarsControllerTest < ActionController::TestCase
  fixtures :avatars, :users

  def test_create
    #    post :create
    user = User.find(1)
    login_as user
    post :create, :user_id => user.id, :redirect => '/me'
    assert_equal 'no image uploaded', flash[:error]

    avatar_image = fixture_file_upload('/files/bee.jpg','image/jpg')
    post :create, :user_id => user.id, :image => {:image_file => avatar_image}, :redirect => '/me'
    assert !flash[:exception]
    assert_redirected_to('/me')
  end

end
