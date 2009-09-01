require 'test_helper'

class ChatChannelTest < Test::Unit::TestCase
  fixtures :users, :groups, :channels, :channels_users, :messages
  set_fixture_class :channels => ChatChannel
  set_fixture_class :channels_users => ChatChannelsUser
  set_fixture_class :messages => ChatMessage

 
  def test_associations
    assert check_associations(ChatChannel)
  end

  def test_channel_without_group
    channel = ChatChannel.new :name => "Channel Without A Group"
    assert_equal channel.save, false, 'should not save channel without a group'
  end

  def test_channel_channels_users
    channel = channels(:rainbow)
    assert_equal channel.channels_users.size, 3, 'should have 3 channels_users'
  end

end
