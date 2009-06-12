module GroupHelper

  include WikiHelper

  def group_cache_key(group, options={})
    params.merge(:version => group.version, :updated_at => group.updated_at.to_i, :lang => session[:language_code]).merge(options)
  end

  ## DEPRECATED. use @group.committee?
  def committee?
    @group.instance_of? Committee
  end

  ## DEPRECATED. use @group.network?
  def network?
    @group.instance_of? Network
  end

  def edit_settings_link
    if may_edit_group?
      link_to 'Edit Settings'[:edit_settings], {:controller => 'groups/basic', :action => 'edit', :id => @group}
    end
  end

  def join_group_link
    return unless logged_in? and !current_user.direct_member_of? @group
    if may_join_membership?
      link_to("join {group_type}"[:join_group, @group.group_type], {:controller => :membership, :action => 'join', :group_id => @group.id})
    elsif may_create_join_requests?
      link_to("request to join {group_type}"[:request_join_group_link, @group.group_type], {:controller => :requests, :action => 'create_join', :group_id => @group.id})
    end
  end

  def group_member?(group = @group)
    logged_in? and current_user.member_of?(group)
  end

  def group_type
    @group_type || (@group.group_type if @group)
  end

  def leave_group_link
    link_to_active_if_may("leave {group_type}"[:leave_group, group_type],
      :membership, 'leave', @group.name)
  end

  def destroy_group_link
    # eventually, this should fire a request to destroy.
    link_if_may "destroy {group_type}"[:destroy_group,group_type],
      :group, 'destroy', @group,
      {:confirm => "Are you sure you want to destroy this %s?".t % group_type, :method => :post}
  end

  def more_committees_link
    ## link_to_iff may_view_committee?, 'view all'[:view_all], ''
  end

  def create_committee_link
    link_if_may 'Create'[:create_button],
      :groups, 'create', nil,
      :parent_id => @group.id
  end


  def list_membership_link(link_suffix='')
    link_to_active_if_may('edit'.t + link_suffix,
                          :membership, 'edit', @group) or
    link_to_active_if_may("See All"[:see_all_link] + link_suffix,
                          :membership, 'list', @group)
  end

  def membership_count_link
    link_if_may("{count} members"[:group_membership_count, {:count=>(@group.users.size).to_s}] + ARROW,
                   :membership, 'list', @group) or
    "{count} members"[:group_membership_count, {:count=>(@group.users.size).to_s}]
  end


  def group_membership_link(link_suffix='')
    link_to_active_if_may "See All"[:see_all_link] + link_suffix,
      :membership, 'groups', @group
  end

  def invite_link(suffix='')
    if may_admin_group?
      link_to_active('send invites'[:send_invites] + suffix, {:controller => 'requests', :action => 'create_invite', :group_id => @group.id})
    end
  end

  def edit_featured_link
    link_if_may "edit featured content"[:edit_featured_content].titlecase,
      :group, 'edit_featured_content', @group
  end

  def edit_group_custom_appearance_link(appearance)
    if appearance and may_admin_group?
      link_to "edit custom appearance"[:edit_custom_appearance], edit_custom_appearance_url(appearance)
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
      link_to_active(:rejected.t, hash.merge(:state => 'rejected'))
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

  #Defaults!
  def show_section(name)
    @group.group_setting ||= GroupSetting.new
    if @group.network?
    end
    default_template_data = {"section1" => "group_wiki", "section2" => "recent_pages"}
    default_template_data.merge!({"section3" => "recent_group_pages"}) if @group.network?

    @group.group_setting.template_data ||= default_template_data
    widgets = @group.group_setting.template_data
    widget = widgets[name]
    @group.network? ? widget_folder =  'network' : widget_folder = 'group'
    render :partial => widget_folder + '/widgets/' + widget if widget.length > 0
  end

#  def select_front_page_image(image_pages, profile)
#    render :partial => 'image_page_swatch', :locals => {:image_pages => image_pages, :profile => profile}
#  end

#  def select_front_page_video(video_pages, profile)
#    render :partial => 'video_page_swatch', :locals => {:video_pages => video_pages, :profile => profile}
#  end

end
