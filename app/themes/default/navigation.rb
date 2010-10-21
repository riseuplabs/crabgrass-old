

navigation do

  ##
  ## HOME

  global_section :home do
    label   "Home"
    visible { !logged_in? || controller?(:account, :session, :root) }
    url     '/'
    active  { controller?(:account, :session, :root) }
  end

  ##

  ##
  ## ME
  ##

  global_section :me do
    label "Me"
    visible { logged_in? }
    url     { me_home_path }
    active  { controller?('me/') }
    html    :partial => '/layouts/navigation/global/me_menu'

    context_section :create_page do
      label  "Create Page"
      url     { new_me_page_path }
      active  false
      icon    :plus
      visible { @drop_down_menu }
    end

    context_section :timeline do
      label  "Timeline"
      url    { me_home_path }
      active { controller?('me/timelines') }
      icon   :clock
    end

    context_section :pages do
      label  "Pages"
      url    { me_pages_path }
      active { controller?('me/pages') }
      icon   :page_white_copy
    end

    context_section :activities do
      label  "Activities"
      url    { me_activities_path }
      active { controller?('me/activities') }
      icon   :transmit
    end

    context_section :messages do
      label  "Messages"
      url    { me_messages_path }
      active { controller?('me/messages') }
      icon   :page_message
    end

    context_section :settings do
      label  "Settings"
      url    { me_settings_path }
      active { controller?('me/settings', 'me/permissions', 'me/profile', 'me/requests') }
      icon   :control

      local_section :settings do
        label  "Account Settings"
        url    { me_settings_path }
        active { controller?('me/settings') }
      end

      local_section :permissions do
        label  "Permissions"
        url    { me_permissions_path }
        active { controller?('me/permissions') }
      end

      local_section :profile do
        label  "Profile"
        url    { me_profile_path }
        active { controller?('me/profile') }
      end

      local_section :requests do
        label  "Requests"
        url    { me_requests_path }
        active { controller?('me/requests') }
      end

    end

  end

  ##
  ## PEOPLE
  ##

  global_section :people do 
    label  "People"
    url    :controller => 'people/directory'
    active { controller?('people/') }
    html    :partial => '/layouts/navigation/global/people_menu'
  end

  ##
  ## GROUPS
  ##
 
  global_section :group do
    visible { @group }
    label  "Groups"
    url    { groups_directory_path }
    active { controller?('groups/') }
    html    :partial => '/layouts/navigation/global/groups_menu'

    context_section :home do
      label  "Home"
      url    { url_for_group(@group) }
      active { controller?('groups/groups') }
    end

    context_section :pages do
      label  "Pages"
      url    { group_pages_path(@group) }
      active { controller?('groups/pages') }
    end

    context_section :members do
      visible { may_list_memberships? }
      label   "Members"
      url     { group_members_path(@group) }
      active  { controller?('groups/members', 'groups/invites') }

      local_section :people do
        visible { may_list_memberships? }
        label   "People"
        url     { group_members_path(@group) }
        active  { controller?('groups/members') }
      end

      local_section :invites do
        visible { may_create_invite_request? }
        label   "Send Invites"
        url     { group_invites_path(@group) }
        active  { controller?('groups/invites') }
      end
    end

    context_section :settings do
      visible { may_edit_group? }
      label  "Settings"
      url    { group_settings_path(@group) }
      active { (controller?('groups/groups') and action?(:edit, :update)) or controller?('groups/requests', 'groups/permissions', 'groups/profile')}

      local_section :permissions do
        visible { may_admin_group? }
        label  "Permissions"
        url    { group_permissions_path(@group) }
        active { controller?('groups/permissions') }
      end

      local_section :profile do
        visible { may_admin_group? }
        label  "Profile"
        url    { group_profile_path(@group) }
        active { controller?('groups/profile') }
      end

      local_section :requests do
        visible { may_admin_requests? }
        label  "Requests"
        url    { group_requests_path(@group) }
        active { controller?('groups/requests') }
      end
    end
  end

  ##
  ## GROUPS DIRECTORY
  ##

  global_section :group_directory do
    visible { @group.nil? }
    label  "Groups"
    url    { groups_directory_path }
    active { controller?('groups/') }
    html    :partial => '/layouts/navigation/global/groups_menu'
##    section :place do
##    end
##    section :location do
##    end
  end

end

