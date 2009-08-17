require 'test_helper'

class ChatChannelsUserTest < Test::Unit::TestCase
  fixtures :users, :groups, :channels, :channels_users, :messages
  set_fixture_class :channels => ChatChannel
  set_fixture_class :channels_users => ChatChannelsUser
  set_fixture_class :messages => ChatMessage

 
  def test_associations
    assert check_associations(ChatChannel)
  end

  def test_channels_user_without_channel
    channel = ChatChannelsUser.new :user => users(:blue)
    assert_equal channel.save, false, 'should not save channels_user without a channel'
  end

  def test_channels_user_without_user
    channel = ChatChannelsUser.new :channel => channels(:rainbow)
    assert_equal channel.save, false, 'should not save channels_user without an user'
  end

end
