module ChatHelper

  def message_time_and_name(created_at, name)
    %(<span class="time">#{created_at.strftime('%Y.%m.%d %R')}</span> <span class="sender">#{name}</span> )
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
    %($('conversation').scrollTop = $('conversation').scrollHeight + $('conversation').clientHeight;)
  end
  
  def insert_message_script(message)
    %(new Insertion.Bottom('stage', '#{escape_javascript message_content(message)}');)
  end

  def record_user_action(action)
    # tell the database that is user is still in the channel, decrement the is_typing counter
    state = Integer(0)
    @channels_user ||= @channel.channels_users.find_by_user_id(@user.id)
    if @channels_user and @channels_user.status?
      state = @channels_user.status
    end
    
    if action == :not_typing
      if state > 0
        state -= 1
      elsif state < 0
        state += 1
      end
    elsif action == :typing
      if state < 0
        state += 1
      else
        state = 3
      end
    elsif action == :just_finished_typing
      state = -2
    end
    
    @channel.users.delete(@user)
    @channel.users.push_with_attributes(@user, { :last_seen => Time.now, :status => state })
  end

  def num_active_in_channel(group_id)
    channel = Channel.find_by_group_id(group_id)
    "(#{channel.active_channel_users.length})" if channel
  end

end

