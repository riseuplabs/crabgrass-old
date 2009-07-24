module ChatHelper

  def message_time_and_name(created_at, name)
    %(<span class="time">#{created_at.strftime('%R')}</span> <span class="sender">#{name}</span> )
  end

  def message_content(message)
    %(<div class="message #{message.level}" id="message-#{message.id}">
      #{message_time_and_name(message.created_at, message.sender_name)}
      <span class="content">#{message.content}</span></div>)
  end

  def set_time_and_name_script
    %(time_and_name = '#{message_time_and_name(Time.now, @user.name)}';)
  end

  def scroll_conversation_script
    "$('conversation').scrollTop = $('conversation').scrollHeight;"
  end

  # this isn't working yet, but is more in the rails way, using JavascriptGenerator
  def scroll_conversation
    conv = page[:conversation]
    if conv.scrollTop > conv.scrollHeight - 2*conv.clientHeight
      conv.scrollTop = conv.scrollHeight - conv.clientHeight
    end
  end

  def insert_message_script(message)
    %(new Insertion.Bottom('conversation', '#{escape_javascript message_content(message)}');)
  end

  def num_active_in_channel(group_id)
    channel = ChatChannel.find_by_group_id(group_id)
    "(#{channel.active_channel_users.length})" if channel
  end

end

