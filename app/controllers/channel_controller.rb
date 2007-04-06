#
# this code was originally free software called Congress,
# but then taken offline by the author.
# The code ended up in Toombila, where this code
# was copied from.
#

class ChannelController < ApplicationController
  
  prepend_before_filter :get_channel_and_user
  
  # http request front door
  # everything else is xhr request.
  def chat
    @channel.destroy_old_messages
    unless @channel.users.include?(@user)
      user_joins_channel(@user, @channel)
      @channel.users.push_with_attributes(@user, { :last_seen => Time.now })
    end
    @messages = @channel.latest_messages
    session[:last_retrieved_message_id] = @messages.last.id if @messages.any?
  end
  
  # Post a user's message to a channel
  def say
    return false unless request.xhr?
    
    # Get the message
    message = params[:message]
    return false unless message
    
    if message.match(/^\/\w+/)
      # It's an IRC style command
      command, arguments = message.scan(/^\/(\w+)(.+?)$/).flatten
      logger.info(command)
      case command
      when 'me'
        user_action_in_channel(@user, @channel, arguments)
        @message = Message.find(:first, :order => "id DESC", :conditions => ["sender_id = ?", @user.id])
      else
        return false
      end
    else
      user_say_in_channel(@user, @channel, message)
      @message = Message.find(:first, :order => "id DESC", :conditions => ["sender_id = ?", @user.id])
    end
    render :layout => false
  end
  
  # Get the latest messages since the user last got any
  def get_latest_messages
    return false unless request.xhr?
    session[:last_retrieved_message_id] ||= 0
    @messages = @channel.messages.since(session[:last_retrieved_message_id])
    session[:last_retrieved_message_id] = @messages.last.id if @messages.any?
    render :layout => false
  end
  
  # Get a list of users for the channel and clean up any who left
  def get_user_list
    return false unless request.xhr?
    
    # Tell the database we're still alive
    @channel.users.delete(@user)
    @channel.users.push_with_attributes(@user, { :last_seen => Time.now })
    
    # Announce any users who just left
    if @channel.users_just_left
      for user in @channel.users_just_left
        user_leaves_channel(user, @channel)
      end
    end
    
    # Do a clean up of users in the channel
    @channel.users.cleanup
    render :layout => false
  end
  
  private
  
  # Get channel and user info that most methods use
  def get_channel_and_user
    @user = current_user
    @channel = Channel.find_by_id(params[:id])
    unless @channel
      @group = Group.find_by_name(params[:id])
      if @group
        @channel = Channel.find_by_group_id(@group.id)
        unless @channel
          @channel = Channel.create(:name => @group.name, :group_id => @group.id)
        end
      end
    end
    true
  end

  def authorized?
    return( @user and @channel and @user.member_of?(@channel.group_id) )
  end
  
  def user_say_in_channel(user, channel, say)
    say = sanitize(say)
    #say = say.gsub(":)", "<img src='../images/emoticons/smiley.png' \/>")
    Message.new(:channel => channel, :content => say, :sender => user).save
  end
  
  def user_action_in_channel(user, channel, say)
    Message.new(:channel => channel, :content => sanitize(say), :sender => user, :level => 'action').save
  end
  
  def user_joins_channel(user, channel)
    Message.new(:channel => channel, :sender => user, :content => "joins the chatroom", :level => 'sys').save
  end
  
  def user_leaves_channel(user, channel)
    Message.new(:channel => channel, :sender => user, :content => "left the chatroom", :level => 'sys').save
  end
  
  def sanitize(say)
    say.gsub!(/\</, '&lt;')
    say.gsub!(/\>/, '&gt;')
    say
  end	  
  
end
