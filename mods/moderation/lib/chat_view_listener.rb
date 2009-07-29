class ChatViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def chat_channel_actions(context)
    link_to('flag as inappropriate', {:controller=> :yucky, :action => :add_chat, :id => context[:group].id})
  end
end

