module ChatPermission 
  #  def authorized?
  #    return false unless current_site.chat?
  #    return true if params[:action] == 'index'
  #    return( @user and @channel and @user.member_of?(@channel.group_id) )
  #  end
  def may_index_chat?()
    current_site.chat?
  end
  
  def may_say_chat?(channel=@channel)
    current_site.chat? and
    logged_in? and 
    current_user.member_of?(channel.group_id)
  end

  %w(channel user_is_typing poll_channel_for_updates).each{ |action|
    alias_method "may_#{action}_chat?".to_sym, :may_say_chat?
  }

end
