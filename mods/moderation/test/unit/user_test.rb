require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    setup_site_with_moderation
  end

  def test_mixin_is_working
    with_site "moderation" do
      assert @mod.respond_to?(:moderator?), 'the moderation user mixin should be applied'
      assert_nothing_raised  'the migrations for the moderation mod should have been run so User#moderator? works.' do
        @mod.moderator?
      end
      assert @mod.moderator?, 'User should be a moderator.'
    end
  end

end

