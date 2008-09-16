module GroupsHelper

  include WikiHelper

  def group_cache_key(group, options={})
    params.merge(:version => group.version, :updated_at => group.updated_at).merge(options)
  end

  def may_admin_group?
    logged_in? and current_user.may?(:admin, @group)
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
        link_to "join %s"[:join_group] % @group_type, 
          url_for(:controller => 'membership', :action => 'list', :id => @group)
      elsif @group.profiles.visible_by(current_user).may_request_membership?
        link_to "join %s"[:join_group] % @group_type, 
         url_for(:controller => '/requests', :action => 'create_join', :group_id => @group.id)
      end
    end
  end

  def group_type
    @group.class.to_s.downcase if @group
  end

  def leave_group_link
    if logged_in? and current_user.direct_member_of? @group and @group.users.uniq.size > 1
	    link_to_active("leave %s"[:leave_group] % group_type, {:controller => 'membership', :action => 'leave', :id => @group.name})
		end
  end
  
  def destroy_group_link
    if logged_in? and current_user.direct_member_of? @group and @group.users.uniq.size == 1
#    if @group.users.uniq.size == 1 and logged_in? and @group.users.include? current_user
          post_to "destroy #{group_type}".t, group_url(:action => 'destroy', :id => @group), :confirm => "Are you sure you want to destroy this %s?".t % group_type
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
      link_to_active 'edit'.t, {:controller => 'membership', :action => 'list', :id => @group.name}
    elsif @group.profiles.visible_by(current_user).may_see_members?
      link_to_active 'view all'.t, {:controller => 'membership', :action => 'list', :id => @group.name}
    end
  end
  
  def invite_link
    if may_admin_group?
      link_to_active('send invites'.t, {:controller => 'requests', :action => 'create_invite', :group_id => @group.id})
    end
  end

  def requests_link
    if may_admin_group?
      link_to_active('view requests'.t, {:controller => 'requests', :action => 'list', :group_id => @group.id})
    end
  end
  
end
