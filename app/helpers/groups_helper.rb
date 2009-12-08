module GroupsHelper

  ##
  ## URLS
  ##

  #def group_settings_url(options)
  #  {:controller => '/groups/basic', :action => 'edit'}.merge(options)
  #end

  #def group_settings_context
  #  add_context(I18n.t(:settings), groups_url(:action => 'edit', :id => @group))
  #end

  ##
  ## NAVIGATION
  ##

  def settings_tabs
    render :partial => 'groups/navigation/settings_tabs'
  end

  def edit_settings_link
    if may_edit_group?
      link_to I18n.t(:edit_settings), groups_url(:action => 'edit', :id => @group)
    end
  end

  def join_group_link
    return unless logged_in? and !current_user.direct_member_of? @group
    if may_join_memberships?
      link_to(I18n.t(:join_group_link, :group_type => @group.group_type), {:controller => 'groups/memberships', :action => 'join', :id => @group}, :method => :post)
    elsif may_create_join_request?
      link_to(I18n.t(:request_join_group_link, :group_type => @group.group_type), {:controller => 'groups/requests', :action => 'create_join', :id => @group})
    end
  end

  def destroy_group_link
    if may_destroy_group?
      link_to_with_confirm(I18n.t(:destroy_group_link, :group_type => @group.group_type),
                        {:confirm => I18n.t(:destroy_confirmation, :thing => @group.group_type.downcase),
                          :ok => I18n.t(:delete_button),
                          :url => groups_url(:action => :destroy),
                          :method => :post})
    elsif may_create_destroy_request?
      if RequestToDestroyOurGroup.pending.for_group(@group).created_by(current_user).blank?
        link_to_with_confirm(I18n.t(:propose_to_destroy_group_link, :group_type => @group.group_type),
                          {:confirm => I18n.t(:propose_to_destroy_group_confirmation, :group_type => @group.group_type.downcase),
                            :ok => I18n.t(:delete_button),
                            # :title => "Destroy Group"
                            :title => I18n.t(:destroy_group_link, :group_type => @group.group_type),
                            :url => {:controller => 'groups/requests', :action => 'create_destroy', :id => @group},
                            :method => :post})
      end
    end
  end

  def more_committees_link
    ## link_to_iff may_view_committee?, I18n.t(:view_all), ''
  end

  def create_committee_link
    if may_create_subcommittees?
      link_to I18n.t(:create_button), committees_params(:action => :new)
    end
  end

  def edit_featured_link(label=nil)
    label ||= I18n.t(:edit_featured_content_link).titlecase
    if may_edit_featured_pages?
      link_to label, groups_features_url(:action => :index)
    end
  end

  def edit_group_custom_appearance_link(appearance)
    if appearance and may_edit_appearance?
      link_to I18n.t(:edit_appearance), edit_custom_appearance_url(appearance)
    end
  end

  ## request navigation

  def requests_link
    if may_create_invite_request?
      link_to_active(I18n.t(:view_requests), {:controller => 'groups/requests', :action => :list, :id => @group})
    end
  end

  def invite_link
    if may_create_invite_request?
      link_to_active(I18n.t(:send_invites), {:controller => 'groups/requests', :action => 'create_invite', :id => @group})
    end
  end

  ## membership navigation

  def list_membership_link
    link_to_active_if_may(I18n.t(:edit), '/groups/memberships', 'edit', @group) or
    link_to_active_if_may(I18n.t(:see_all_link), '/groups/memberships', 'list', @group)
  end

  def membership_count_link
    link_if_may(I18n.t(:group_membership_count, :count=>(@group.users.size).to_s) + ARROW,
                   '/groups/memberships', 'list', @group) or
    I18n.t(:group_membership_count, :count=>(@group.users.size).to_s)
  end


  def group_membership_link
    link_to_active_if_may I18n.t(:see_all_link), '/groups/memberships', 'groups', @group
  end

  def leave_group_link
    link_to_active_if_may(I18n.t(:leave_group_link, :group_type => @group.group_type),
      '/groups/memberships', 'leave', @group)
  end

  def destroy_membership_link(membership)
    user, group = membership.user, membership.group

    # can't remove yourself from the group this way - have to use the 'Leave Group' link
    return if user == current_user
    if may_destroy_memberships?(membership)
      link_to(I18n.t(:remove), {:controller => '/groups/memberships', :action => 'destroy', :id => membership},
            :confirm => I18n.t(:membership_destroy_confirm_message, :user => user.display_name, :group_type => group.group_type.downcase),
            :method => :delete)
    end
  end

  ##
  ## LAYOUT
  ##

  def show_section(name)
    @group.group_setting ||= GroupSetting.new
    default_template_data = {"section1" => "group_wiki", "section2" => "recent_pages"}
    default_template_data.merge!({"section3" => "recent_group_pages"}) if @group.network?

    @group.group_setting.template_data ||= default_template_data
    widgets = @group.group_setting.template_data
    widget = widgets[name]
    #@group.network? ? widget_folder =  'network' : widget_folder = 'group'
    render :partial => '/widgets/' + widget if widget.length > 0
  end

  ##
  ## CREATION
  ##

  def create_group_link
    if @active_tab == :groups
      if may_create_group?
        link_to_with_icon('plus', I18n.t(:create_a_new_thing, :thing => I18n.t(:group).downcase), groups_url(:action => 'new'))
      end
    elsif @active_tab == :networks
      if may_create_network?
        link_to_with_icon('plus', I18n.t(:create_a_new_thing, :thing => I18n.t(:network).downcase), networks_url(:action => 'new'))
      end
    end
  end

  ##
  ## TAGGING
  ##

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
    link_to tag.name, groups_url(:action => 'tags') + '/' + path.join('/'), options
  end

end
