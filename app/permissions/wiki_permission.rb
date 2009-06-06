module WikiPermission 
  #  def authorized?
  #    logged_in? and current_user.member_of?(@group)
  #  end
  def may_edit_wiki?(group=@group)
    logged_in? and current_user.member_of?(group)
  end

  %w(old_version edit_area save done).each{ |action|
    alias_method "may_#{action}_messages?".to_sym, :may_edit_wiki?
  }

end
