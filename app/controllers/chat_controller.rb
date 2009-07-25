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
        if group.chat_channel
          channel_users[group] = group.chat_channel.active_channel_users.size
        else
          channel_users[group] = 0
        end
      end
      @group_array = channel_users.sort {|a,b| a[1] <=> b[1]}
      @group_array.reverse!
    end
  end

  # http request front door
  # everything else is xhr request.
  def channel
    #unless @channel.users.include?(@user)
      user_joins_channel(@user, @channel)
    #end
    @channel_user.record_user_action :not_typing
    @messages = @channel.latest_messages
    session[:last_retrieved_message_id] = @messages.last.id if @messages.any?
    @html_title = Time.now.strftime('%Y.%m.%d')
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
        @message = ChatMessage.find(:first, :order => "id DESC", :conditions => ["sender_id = ?", @user.id])
      else
        return false
      end
    else
      user_say_in_channel(@user, @channel, message)
      @message = ChatMessage.find(:first, :order => "id DESC", :conditions => ["sender_id = ?", @user.id])
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
    session[:last_retrieved_message_id] ||= 0
    @messages = @channel.messages.since(session[:last_retrieved_message_id])
    session[:last_retrieved_message_id] = @messages.last.id if @messages.any?

    @channel_user.record_user_action :not_typing

    render :layout => false
  end

  def user_list
    @channel.users_just_left.each do |ex_user|
      user_leaves_channel(ex_user.user, @channel)
      ex_user.destroy
    end

    @channel_user.record_user_action

    render :partial => 'chat/userlist', :layout => false
  end

  def leave_channel
     user_leaves_channel(@user, @channel)
     @channel_user.destroy
     redirect_to :controller => :me, :action => :dashboard
  end

  def archive
    @path = params[:path] || []
    @parsed = parse_filter_path(params[:path])
    @months = ChatMessage.months(@channel)
    unless @months.empty?
      @current_year  = (Date.today).year
      @start_year    = @months[0]['year'] || @current_year.to_s
      @current_month = (Date.today).month

      # normalize path
      unless @parsed.keyword?('date')
        @path << 'date'<< "%s-%s" % [@months.last['year'], @months.last['month']]
      end
      @parsed = parse_filter_path(@path)
      date = @parsed.keyword?('date')[1]
      date =~ /(\d{4})-(\d{1,2})-?(\d{0,2})/
      @year = year = $1
      @month = month = $2
      @day = day = $3
      unless day.empty?
        @messages = []
        ChatMessage.for_day(@channel, year, month, day).each do |m|
          @messages << "#{m.sender_name}: #{m.content}"
        end
      else
        @days = ChatMessage.days(@channel, year, month)
      end
    end
  end

  private

  # Get channel and user info that most methods use
  def get_channel_and_user
    @user = current_user
    @channel = ChatChannel.find_by_id(params[:id]) if params[:id].is_a? Numeric
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
    @channel_user = ChatChannelsUser.create({:channel => @channel, :user => @user}) if  (!@channel_user and @user.is_a? User)
    true
  end


  def user_say_in_channel(user, channel, say)
    say = sanitize(say)
    #say = say.gsub(":)", "<img src='../images/emoticons/smiley.png' \/>")
    ChatMessage.new(:channel => channel, :content => say, :sender => user).save
  end

  def user_action_in_channel(user, channel, say)
    ChatMessage.new(:channel => channel, :content => sanitize(say), :sender => user, :level => 'action').save
  end

  def user_joins_channel(user, channel)
    ChatMessage.new(:channel => channel, :sender => user, :content => :joins_the_chatroom.t, :level => 'sys').save
  end

  def user_leaves_channel(user, channel)
    ChatMessage.new(:channel => channel, :sender => user, :content => :left_the_chatroom.t, :level => 'sys').save
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
    @active_tab = :chat
  end

end
