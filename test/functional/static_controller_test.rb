require File.dirname(__FILE__) + '/../test_helper'

class StaticControllerTest < ActionController::TestCase
  fixtures :avatars

  def test_avatar
    get :avatar, :id => 0
    assert_response :success

    post :avatar, :id => 0, :size => 'large'
    assert_response :success
  end

  # TODO: it would be nice to have tests for an avatar other than the default...
end
