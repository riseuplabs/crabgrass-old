require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  # We need a hostname in order to construct a Jabber ID for each user.
  DOMAIN = UserExtension::DOMAIN

  # Common definitions for all tests.
  def setup
    @user_one = users(:quentin)
    @user_two = users(:aaron)
    @conditions = { :username => @user_one.login,
                    :jid      => "#{@user_two.login}@#{DOMAIN}" }
  end

  # Our Observer should create a UserRoster and GroupRoster pair
  # for a new contacts when contacts are created.
  def test_create_user_roster_and_group_roster 
    @user_one.add_contact!(@user_two)
    assert UserRoster.find(:first, :conditions => @conditions), "UserRoster should exist"
    assert GroupRoster.find(:first, :conditions => @conditions), "GroupRoster should exist"
  end

  # Our Observer should delete the UserRoster and GroupRoster pair
  # when a contact is deleted.
  def test_destroy_user_roster_and_group_roster
    @user_one.add_contact!(@user_two)
    @user_one.remove_contact!(@user_two)
    assert_nil UserRoster.find(:first, :conditions => @conditions), "UserRoster shouldn't exist"
    assert_nil GroupRoster.find(:first, :conditions => @conditions), "GroupRoster should exist"
  end
end
