module PersonHelper

  def friend_link
    if logged_in?
      if @user.friend_of?(current_user)
        link_to "Remove from my contacts"[:remove_friend_link], {:controller => 'contact', :action => 'remove', :id => @user}
      elsif @user.profiles.visible_by(current_user).may_request_contact?
        link_to "Add to my contacts"[:request_friend_link], {:controller => 'contact', :action => 'add', :id => @user}
      end
    end
  end

end

