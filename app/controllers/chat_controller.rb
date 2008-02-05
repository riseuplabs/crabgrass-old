#
# There was once a free software demo of chat in rails.
# Eventually, the code was taken offline by the author.
# and later ended up in Toombila.
#
# This chat is inspired by the code from toombila.
#

class ChatController < ApplicationController
  include ChatHelper
 
  before_filter :login_required 
  prepend_before_filter :get_channel_and_user
  
  # show a list of available channels
  def index
    if logged_in?
      @groups = current_user.groups
    end
  end
  
  
  # http request front door
  # everything else is xhr request.
  def channel
    @channel.destroy_old_messages
    unless @channel.users.include?(@user)
      user_joins_channel(@user, @channel)
      record_user_action :not_typing
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

    record_user_action :just_finished_typing
 
    render :layout => false
  end

  def user_is_typing
    return false unless request.xhr?
    record_user_action :typing
    render :nothing => true
  end
  
  # Get the latest messages since the user last got any
  def poll_channel_for_updates
    return false unless request.xhr?

    # get latest messages, update id of last seen message
    session[:last_retrieved_message_id] ||= 0
    @messages = @channel.messages.since(session[:last_retrieved_message_id])
    session[:last_retrieved_message_id] = @messages.last.id if @messages.any?
    
    record_user_action :not_typing
    
    render :layout => false
  end
  
  private
  
  # Get channel and user info that most methods use
  def get_channel_and_user
    @user = current_user
    @channel = Channel.find_by_id(params[:id])
    unless @channel
      @group = Group.get_by_name(params[:id])
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
    return true if params[:action] == 'index'
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
# we'll use GreenCloth to process the say string --- 
# this makes links clickable, and allows inline images, 
# and can easily be extended to use smilies, etc...
#
# the only trick is that GreenCloth returns the text wrapped
# in a paragraph block (<p> stuff </p>), and things will
# look funny if we don't strip that off
    say  = GreenCloth.new(say).to_html
    say.gsub!(/^<p>/, '')
    say.gsub!(/<\/p>$/, '')
    return say
  end
  
  def breadcrumbs
    add_context 'chat', '/chat'
    add_context @channel.name, url_for(:controller => 'chat', :action => 'channel', :id => @channel.name) if @channel
  end
  
end
