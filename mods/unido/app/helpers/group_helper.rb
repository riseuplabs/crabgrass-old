module GroupHelper
  def join_group_link
    if logged_in? && @group.type != 'Network'
      if current_user.direct_member_of? @group
        return nil
      elsif current_user.member_of? @group
        # if you are an indirect member of this group then (1) it is a committee and (2) you are a member of the group containing it, so you may add yourself to the committee from the edit page.  This may not be true when networks are implemented.
        link_to "join %s"[:join_group] % @group_type, 
          url_for(:controller => '/membership', :action => 'join', :id => @group)
      elsif @group.profiles.visible_by(current_user).may_request_membership?
        link_to "join %s"[:join_group] % @group_type, 
         url_for(:controller => '/requests', :action => 'create_join', :group_id => @group.id)
      end
    end
  end
end