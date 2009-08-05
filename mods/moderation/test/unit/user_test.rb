require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :sites, :groups, :pages, :posts, :memberships

  def setup
    enable_site_testing("moderation")
  end

  def test_mixin_is_working
    assert User.first.respond_to?(:moderator?), 'the moderation user mixin should be applied'
    assert_nothing_raised  'the migrations for the moderation mod should have been run so User#moderator? works.' do
      users(:blue).moderator?
    end
    assert users(:blue).moderator?, 'Blue should be a moderator - please set up the fixtures accordingly.'
  end

end

