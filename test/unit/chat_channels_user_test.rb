require 'test_helper'

class ChatChannelsUserTest < Test::Unit::TestCase
  fixtures :users, :groups, :channels, :channels_users, :messages
  set_fixture_class :channels => ChatChannel
  set_fixture_class :channels_users => ChatChannelsUser
  set_fixture_class :messages => ChatMessage

 
  def test_associations
    assert check_associations(ChatChannelsUser)
  end

  def test_channels_user_without_channel
    channels_user = ChatChannelsUser.new :user => users(:blue)
    assert_equal channels_user.save, false, 'should not save channels_user without a channel'
  end

  def test_channels_user_without_user
    channels_user = ChatChannelsUser.new :chat_channel => channels(:rainbow)
    assert_equal channels_user.save, false, 'should not save channels_user without an user'
  end

  def test_channels_user_without_user_nor_channel
    channels_user = ChatChannelsUser.new
    assert_equal channels_user.save, false, 'should not save channels_user without an nor channel'
  end

end
