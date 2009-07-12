
module MessagesPermission
  def may_show_messages?(user=@user)
    logged_in? and user and
    user.profiles.visible_by(current_user).may_see?
  end

  alias_method :may_index_messages?, :may_show_messages?
  alias_method :may_create_messages?, :may_show_messages?

  def may_destroy_messages?(user=@user, post=@post)
    if !logged_in?
      false
    elsif user == current_user
      true # you can always delete the messages on your own wall
    elsif post and post.user == current_user
      true # you can delete messages you created
    else
      false
    end
  end

  alias_method :may_set_status_messages?, :may_destroy_messages?
end

