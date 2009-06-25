# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    return false unless current_site.chat?
#    return true if params[:action] == 'index'
#    return( @user and @channel and @user.member_of?(@channel.group_id) )
#  end
module ChatPermission
  def may_index_chat?
    current_site.chat?
  end

  def may_say_chat?(channel=@channel)
    current_site.chat? and
    logged_in? and
    current_user.member_of?(channel.group_id)
  end

  alias_method :may_channel_chat?, :may_say_chat?
  alias_method :may_user_is_typing_chat?, :may_say_chat?
  alias_method :may_poll_channel_for_updates_chat?, :may_say_chat?
  alias_method :may_user_list_chat?, :may_say_chat?
end
