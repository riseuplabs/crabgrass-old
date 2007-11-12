module GroupsHelper

  include PageFinders

  def may_admin_group?
    logged_in? and current_user.member_of? @group
# slower way, but was working better before
#    logged_in? and @group.users.include? current_user
  end
    
  def committee?
    @group.instance_of? Committee
  end
  
  def network?
    @group.instance_of? Network
  end
  
  def edit_settings_link
    if may_admin_group?
      link_to 'edit settings'.t, group_url(:action => 'edit', :id => @group)
    end
  end
  
  def join_group_link
    if logged_in?
      if current_user.direct_member_of? @group
        return
      elsif current_user.member_of? @group
        # if you are an indirect member of this group then (1) it is a committee and (2) you are a member of the group containing it, so you may add yourself to the committee from the edit page.  This may not be true when networks are implemented.
        link_to "join #{@group_type}".t, url_for(:controller => 'membership', :action => 'list', :id => @group)
      elsif @group.accept_new_membership_requests
        link_to "join #{@group_type}".t, url_for(:controller => 'membership', :action => 'join', :id => @group)
      end
    end
  end

  def leave_group_link
    if logged_in? and current_user.direct_member_of? @group and @group.users.uniq.size > 1
#    if @group.users.uniq.size > 1 and logged_in? and @group.users.include? current_user
	    link_to "leave #{@group_type}".t, url_for(:controller => 'membership', :action => 'leave', :id => @group)
	    #, :confirm => "Are you sure you want to leave this %s?".t % @group_type
		end
  end
  
  def destroy_group_link
    if logged_in? and current_user.direct_member_of? @group and @group.users.uniq.size == 1
#    if @group.users.uniq.size == 1 and logged_in? and @group.users.include? current_user
          post_to "destroy #{@group_type}".t, group_url(:action => 'destroy', :id => @group), :confirm => "Are you sure you want to destroy this %s?".t % @group_type
    end
  end
    
  def more_committees_link
    link_to 'view all', ''
  end
  
  def create_committee_link
    if may_admin_group?
      link_to 'create committee'.t, group_url(:action => 'create', :parent_id => @group.id)
    end
  end
  
  def more_members_link
    if may_admin_group?
      link_to 'edit'.t, url_for(:controller => 'membership', :action => 'list', :id => @group)
    else
      link_to 'view all'.t, url_for(:controller => 'membership', :action => 'list', :id => @group)
    end
  end
  
  def invite_link
    if may_admin_group?
      link_to 'send invites'.t, url_for(:controller => 'membership', :action => 'invite', :id => @group)
    end
  end

  def requests_link
    if may_admin_group?
      link_to 'view requests'.t, url_for(:controller => 'membership', :action => 'requests', :id => @group)
    end
  end
  
end
