require File.dirname(__FILE__) + '/../test_helper'

class Admin::BaseControllerTest < ActionController::TestCase

  def setup
    setup_site_with_moderation
  end

  def test_user_authorization
    with_site "moderation" do
      login_as @mod
      get :index
      assert @controller.current_user.moderator?, 'mod should be a moderator'
    end
  end

end

