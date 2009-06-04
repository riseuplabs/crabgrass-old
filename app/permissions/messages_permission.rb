module MessagesPermission 
  #  def authorized?
  #    if !logged_in? or @user.nil?
  #      false
  #    elsif action?(:destroy, :set_status)
  #      current_user == @user
  #    else
  #      @profile = @user.profiles.visible_by(current_user)
  #      @profile.may_see?
  #    end
  #  end
  def may_show_messages?(user=@user)
    logged_in? and user and
    user.profiles.visible_by(current_user).may_see?
  end

  %w(index create).each{ |action|
    alias_method "may_#{action}_messages?".to_sym, :may_show_messages?
  }
  
  def may_destroy_messages?(user=@user)
    logged_in? and user == current_user
  end

  %w(set_status).each{ |action|
    alias_method "may_#{action}_messages?".to_sym, :may_destroy_messages?
  }
end
