#
# There was once a free software demo of chat in rails.
# Eventually, the code was taken offline by the author.
# and later ended up in Toombila.
#
# This chat is inspired by the code from toombila.
#

class ChatController < ApplicationController
  include ChatHelper
  stylesheet 'chat'
  stylesheet 'groups'
  permissions 'chat'
  before_filter :login_required
  prepend_before_filter :get_channel_and_user, :except => :index
  append_before_filter :breadcrumbs

  # show a list of available channels
  def index
    if logged_in?
      @groups = current_user.all_groups
      channel_users = {}
      @groups.each do |group|
        channel_users[group] = group.chat_channel ? group.chat_channel.users.size : 0
      end
      @group_array = channel_users.sort {|a,b| a[1] <=> b[1]}
      @group_array.reverse!
    end
  end

  # http request front door
  # everything else is xhr request.
  def channel
    user_joins_channel(@user, @channel)
    @messages = [@channel_user.join_message]
    message_id = @messages.last.id
    session[:first_retrieved_message_id] = message_id
    session[:last_retrieved_message_id] = message_id
    @channel_user.record_user_action :not_typing
    @html_title = Time.zone.now.strftime('%Y.%m.%d')
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
        @message = user_action_in_channel(@user, @channel, arguments)
      else
        return false
      end
    else
      @message = user_say_in_channel(@user, @channel, message)
    end
    @channel_user.record_user_action :just_finished_typing

    render :layout => false
  end

  def user_is_typing
    return false unless request.xhr?
    @channel_user.record_user_action :typing
    render :nothing => true
  end

  # Get the latest messages since the user last got any
  def poll_channel_for_updates
    return false unless request.xhr?

    # get latest messages, update id of last seen message
    @messages = @channel.messages.since(session[:last_retrieved_message_id])
    session[:last_retrieved_message_id] = @messages.last.id if @messages.any?

    # deleted messages
    @deleted_messages = ChatMessage.all(:conditions => ["id > ? AND channel_id = ? AND deleted_at IS NOT NULL", session[:first_retrieved_message_id], @channel.id])

    @channel_user.record_user_action :not_typing

    render :layout => false
  end

  def user_list
    render :partial => 'chat/userlist', :layout => false
  end

  def leave_channel
     user_leaves_channel(@user, @channel)
     @channel_user.destroy
     redirect_to :controller => :me, :action => :dashboard
  end

  def archive
    @months = @channel.messages.months
    unless @months.empty?
      @current_year  = Time.zone.now.year
      @start_year    = @months[0]['year'] || @current_year.to_s
      @current_month = Time.zone.now.month
      @date = params[:date] ? params[:date] : "%s-%s" % [@months.last['year'], @months.last['month']]
      @date =~ /(\d{4})-(\d{1,2})-?(\d{0,2})/
      @year = $1
      @month = $2
      @day = $3
      unless @day.empty?
        @messages = @channel.messages.for_day(@year, @month, @day)
        @html_title = Time.zone.local(@year, @month, @day).strftime('%Y.%m.%d')
      else
        @days = @channel.messages.days(@year, @month)
      end
    end
  end

  private

  # Get channel and user info that most methods use
  def get_channel_and_user
    @user = current_user
    @channel = ChatChannel.find_by_id(params[:id]) if params[:id] !~ /\D/
    unless @channel
      @group = Group.find_by_name(params[:id])
      if @group
        @channel = ChatChannel.find_by_group_id(@group.id)
        unless @channel
          @channel = ChatChannel.create(:name => @group.name, :group_id => @group.id)
        end
      end
    end
    @channel_user = ChatChannelsUser.find(:first,
                                          :conditions => {:channel_id => @channel,
                                                          :user_id => @user})
    if (!@channel_user and (@user.is_a? User) and (action_name != 'archive'))
      @channel_user = ChatChannelsUser.create!({:channel => @channel, :user => @user})
    end
    true
  end


  def user_say_in_channel(user, channel, say)
    say = sanitize(say)
    #say = say.gsub(":)", "<img src='../images/emoticons/smiley.png' \/>")
    ChatMessage.create(:channel => channel, :content => say, :sender => user)
  end

  def user_action_in_channel(user, channel, say)
    ChatMessage.create(:channel => channel, :content => sanitize(say), :sender => user, :level => 'action')
  end

  def user_joins_channel(user, channel)
    ChatMessage.create(:channel => channel, :sender => user, :content => I18n.t(:joins_the_chatroom), :level => 'sys')
  end

  def user_leaves_channel(user, channel)
    ChatMessage.create(:channel => channel, :sender => user, :content => I18n.t(:left_the_chatroom), :level => 'sys')
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
    say.gsub! /\A<p>(.+)<\/p>\Z/m, '\1'
    return say
  end

  def breadcrumbs
    add_context 'chat', '/chat'
    add_context @channel.name, url_for(:controller => 'chat', :action => 'channel', :id => @channel.name) if @channel
    @active_tab = :chat
  end

end
