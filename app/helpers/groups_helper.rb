module GroupsHelper

  include PageFinders

  def may_admin_group?
    logged_in? and current_user.member_of? @group
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
  
  def leave_group_link
    if logged_in? and current_user.direct_member_of? @group
	    link_to "leave #{@group_type}".t, url_for(:controller => 'membership', :action => 'leave', :id => @group)
	    #, :confirm => "Are you sure you want to leave this #{@group_type}?"
		end
  end
  
  def join_group_link
    unless logged_in? and current_user.direct_member_of?(@group)
      link_to "join #{@group_type}".t, url_for(:controller => 'membership', :action => 'join', :id => @group)
    end
  end

  def destroy_group_link
    if @group.users.size == 1 and current_user.direct_member_of? @group
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
