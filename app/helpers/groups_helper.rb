module GroupsHelper

  include PageFinders
  
  def committee?
    @group.instance_of? Committee
  end
  
  def network?
    @group.instance_of? Network
  end

  # makes this: link | link | link
  def link_line(*links)
    "<div class='link_line'>" + links.compact.join(' | ') + "</div>"
  end
  
  def edit_settings_link
    link_to 'edit settings'.t, group_url(:action => 'edit', :id => @group)
  end
  
  def leave_group_link
    if logged_in? and current_user.direct_member_of? @group
	    post_to "leave #{@group_type}", group_url(:action => 'leave_group', :id => @group), :confirm => "Are you sure you want to leave this #{@group_type}?"
		end
  end
  
  def join_group_link
    unless logged_in? and current_user.direct_member_of?(@group)
      post_to "join #{@group_type}", group_url(:action => 'join_group', :id => @group)
    end
  end
  
  def more_committees_link
    link_to 'view all', ''
  end
  
  def create_committee_link
    link_to 'create committee'.t, group_url(:action => 'create', :parent_id => @group.id)
  end
  
  def more_members_link
    link_to 'view all'.t, group_url(:action => 'members', :id => @group)
  end
  
  def edit_members_link
    if logged_in? and current_user.member_of?(@group)
      link_to 'edit'.t, group_url(:action => 'members', :id => @group)
    end
  end
  
end
