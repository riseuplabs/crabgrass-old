module GroupHelper

  include WikiHelper

  def group_cache_key(group, options={})
    params.merge(:version => group.version, :updated_at => group.updated_at.to_i, :lang => session[:language_code]).merge(options)
  end

  def may_admin_group?
    logged_in? and current_user.may?(:admin, @group)
  end

  def group_member?
    logged_in? and current_user.member_of?(@group)
  end

  def committee?
    @group.instance_of? Committee
  end
  
  def network?
    @group.instance_of? Network
  end
  
  def edit_settings_link
    if may_admin_group?
      link_to 'edit settings'[:edit_settings], group_url(:action => 'edit', :id => @group)
    end
  end
  
  def join_group_link
    if logged_in?
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

  def group_type
    @group_type || (@group.class.to_s.downcase if @group)
  end

  def leave_group_link
    if logged_in? and current_user.direct_member_of?(@group) and (@group.network? or @group.users.uniq.size > 1)
	    link_to_active("leave %s"[:leave_group] % group_type, {:controller => 'membership', :action => 'leave', :id => @group.name})
		end
  end
  
  def destroy_group_link
    if may_admin_group?
      # eventually, this should fire a request to destroy.
      if (@group.network? && @group.groups.size == 1) or (@group.users.uniq.size == 1)
        post_to "destroy %s"[:destroy_group] % group_type, group_url(:action => 'destroy', :id => @group), :confirm => "Are you sure you want to destroy this %s?".t % group_type
      end
    end
  end
    
  def more_committees_link
    link_to 'view all'[:view_all], ''
  end
  
  def create_committee_link
    if may_admin_group?
      link_to 'create committee'[:create_committee], groups_url(:action => 'create', :parent_id => @group.id)
    end
  end
  
  def list_membership_url() {:controller => 'membership', :action => 'list', :id => @group.name} end

  def list_membership_link(link_suffix='')
    text = ''
    if may_admin_group?
      text = 'edit'.t
    elsif may_see_members?
      text = 'see all'.t
    end
    if text.any?
      link_to_active text+link_suffix, list_membership_url
    end
  end
  
  def invite_link(suffix='')
    if may_admin_group?
      link_to_active('send invites'[:send_invites] + suffix, {:controller => 'requests', :action => 'create_invite', :group_id => @group.id})
    end
  end

  def edit_featured_link
    if may_admin_group?
      link_to "edit featured content"[:edit_featured_content], group_url(:action => 'edit_featured_content', :id => @group)
    end
  end

  def requests_link(suffix='')
    if may_admin_group?
      link_to_active('view requests'[:view_requests]+suffix, {:controller => 'requests', :action => 'list', :group_id => @group.id})
    end
  end
  
  def request_state_links
    hash = {:controller => params[:controller], :action => params[:action], :group_id => params[:group_id]}

    content_tag :div, link_line(
      link_to_active(:pending.t, hash.merge(:state => 'pending')),
      link_to_active(:approved.t, hash.merge(:state => 'approved')),
      link_to_active(:rejected.t, hash.merge(:state => 'rejected')),
      link_to_active(:ignored.t, hash.merge(:state => 'ignored'))
    ), :style => 'margin-bottom: 1em'
  end

  def link_to_group_tag(tag,options)
    options[:class] ||= ""
    path = (params[:path]||[]).dup
    name = tag.name.gsub(' ','+')
    if path.delete(name)
      options[:class] += ' invert'
    else
      path << name
    end
    options[:title] = tag.name
    link_to tag.name, group_url(:id => @group, :action => 'tags') + '/' + path.join('/'), options
  end
  
  def may_see_members?
    may_see_members_of?(@group)
  end

  def may_see_members_of? group
    if logged_in?
      current_user.may?(:admin,group) || current_user.member_of?(group) || group.profiles.visible_by(current_user).may_see_members?
    else
      group.profiles.public.may_see_members?
    end
  end

  def may_see_committees?
    return if @group.committee?
    if logged_in?
      current_user.member_of?(@group) || @group.profiles.visible_by(current_user).may_see_committees?
    else
      @group.profiles.public.may_see_committees?
    end
  end

  def may_see_networks?
    if logged_in?
      current_user.member_of?(@group) || @group.profiles.visible_by(current_user).may_see_members?
    else
      @group.profiles.public.may_see_members?
    end
  end

  #Defaults!
  def show_section(name)
    @group.group_setting ||= GroupSetting.new
    @group.group_setting.template_data ||= {"section1" => "group_wiki", "section2" => "recent_pages"}
    widgets = @group.group_setting.template_data
    widget = widgets[name]
    #template = widget[0]
    #local_vars = widget[1]
    render :partial => 'group/widgets/' + widget if widget.length > 0#, :locals => local_vars
  end
end
