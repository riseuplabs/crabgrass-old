require 'test_helper'

class ChatMessageTest < Test::Unit::TestCase
  fixtures :users, :groups, :channels, :channels_users, :messages
  set_fixture_class :channels => ChatChannel
  set_fixture_class :channels_users => ChatChannelsUser
  set_fixture_class :messages => ChatMessage
 
  def test_associations
    assert check_associations(ChatMessage)
  end

  def test_message_without_channel
    message = ChatMessage.new :sender => users(:blue), :content => 'test'
    assert_equal message.save, false, 'should not save channel_message without a channel'
  end

end
