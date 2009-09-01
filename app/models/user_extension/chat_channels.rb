#
# A user's relationship to chat channels
#
# "chat_channels_users" is the join table:
#   user has many chat_channels through chat_channels_users
#   chat_channel has many users through chat_channels_users
#
module UserExtension::ChatChannels

  ##
  ## ASSOCIATIONS
  ##
  def self.included(base)
    base.instance_eval do
      has_many :channels_users, :dependent => :delete_all, :class_name => 'ChatChannelsUser', :foreign_key => 'user_id'
      has_many :chat_channels, :through => :channels_users
    end
  end
end
