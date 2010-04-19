require File.dirname(__FILE__) + '/../test_helper'

class Moderation::Admin
  class BaseControllerTest < Mod::Controller::TestCase
    skip_if :mod_disabled_or_migrations_fail?

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
end
