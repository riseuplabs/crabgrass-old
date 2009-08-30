module BasePage::ShareHelper

#  def page_access_options
#    [['Coordinator'[:coordinator],'admin'],['Participant'[:participant],'edit'],['Viewer'[:viewer],'view']]
#  end

  def page_access_options(options={})
    @access_options ||= [
      ['Full Access'[:page_access_admin],'admin'],
      ['Write Ability'[:page_access_edit],'edit'],
      ['Read Only'[:page_access_view],'view']
    ]
    if options[:remove]
      @access_options + [['No Access'[:page_access_none],'remove']]
    elsif options[:blank]
      @access_options + [["(%s)" % 'No Change'[:no_change],'']]
    else
      @access_options
    end
  end

  # displays the access level of a participation.
  # eg:
  #   <span class="admin">Full Access</span>
  #
  def display_access(participation)
    if participation
      access = participation.access_sym.to_s
      option = page_access_options.find{|option| option[1] == access}
      content_tag :span, option[0], :class => access
    end
  end

  def display_access_icon(participation)
    icon = case participation.access_sym
      when :admin then 'tiny_wrench'
      when :edit then 'tiny_pencil'
      when :view then 'tiny_no_pencil'
    end
    icon_tag(icon)
  end

  #
  # creates a select tag for page access
  #
  # There are two forms:
  #
  #   select_page_access(name, participation, options)
  #   select_page_access(name, options)
  #
  # options:
  #
  #  [blank] if true, include 'no change' as an option
  #  [expand] if true, show as list instead of popup.
  #  [remove] if true, show an entry that allows for access removal
  #
  def select_page_access(name, participation={}, options=nil)
    options = participation if participation.is_a?(Hash)

    selected = participation.try(:access_sym) || options[:selected]
    options.reverse_merge!(:blank => true, :expand => false, :remove => false, :class => 'access')

    select_options = page_access_options(:blank => options[:blank], :remove => options.delete(:remove))
    if options.delete(:blank)
      selected ||= ''
    else
      selected ||= Conf.default_page_access
    end
    if options.delete(:expand)
      options[:size] = select_options.size
    end
    select_tag name, options_for_select(select_options, selected.to_s), options
  end

  ##
  ## STUFF FOR SHARE WITH EVERYONE
  ##

  def check_box_options
    recipient = Site.current.network
    old_participation = @page.try.participation_for_group(recipient)
    disabled = !old_participation.nil?
    in_list = @recipients.try.include?(recipient)
    access = old_participation.try.access
    spinner_id = "add_site"

    id = "share_recipient_%s" % recipient.name
    add_function = remote_function(add_action(recipient, access, id))
    remove_function = "$('%s').remove()" % id
    toggle_function = "if ($('#{id}') == null)
      { #{add_function} } else
      { #{remove_function} }"
    # disabling form elements does not work with ie6.
    # so we just keep them enabled.
    # unless disabled
    { :onclick => toggle_function,
      :checked => in_list || disabled }
    #,:disabled => disabled }
  end


  def access_options
    recipient = Site.current.network
    old_participation = @page.try.participation_for_group(recipient)
    access = old_participation.try.access
    access ||= may_select_access_participation? ?
      "$('recipient[access]').value" :
      "'#{Conf.default_page_access}'"
    other_select = "$('recipients[#{recipient.name.gsub(/\+/,"%2b")}][access]')"
    this_select = "$('share_with_everyone_access')"
    sync_function = "#{other_select}.value = #{this_select}.value"

    {:blank => false, :selected => access, :onchange => sync_function} # :disabled => disabled
  end

  protected

  def add_action(recipient, access, spinner_id)
    access ||= may_select_access_participation? ?
      "$('recipient[access]').value" :
      "'#{Conf.default_page_access}'"
    {
      :url => {:controller => 'base_page/share', :action => 'update', :page_id => nil, :add => true},
      :with => %{'recipient[name]=#{recipient.name}&recipient[access]=' + #{access}},
      :loading => spinner_icon_on('spacer', spinner_id),
      :complete => spinner_icon_off('spacer', spinner_id)
      }
  end


end


  ##
  ## PAGE SHARING FORM
  ##

=begin
  def setup_sharing_populations
    if @share_groups.nil?
      @share_page_groups    = @page ? @page.namespace_groups : []
      @share_contributors   = @page ? @page.contributors : []
      all_groups = current_user.all_groups.sort_by {|g|g.name}
      @share_groups      = current_user.all_groups.select {|g|g.normal?}
      @share_networks    = current_user.all_groups.select {|g|g.network?}
      @share_committees  = current_user.all_groups.select {|g|g.committee?}
      @share_friends        = current_user.contacts.sort_by{|u|u.name}
      @share_peers          = current_user.peers.sort_by{|u|u.name}

      params[:recipients] ||= {}
      if params[:group] and (group = Group.find_by_name(params[:group]))
        params[:recipients][group.name] = "1"
        params[:access] = 'admin'
      end
    end
  end

  def share_page_recipient_tabs
    setup_sharing_populations
    Formy.tabs('class' => 'left') do |f|
      if @share_page_groups.any?
        f.tab do |t|
          t.label "Page groups"[:share_page_groups]
          t.show_tab 'share_population_groups'
          t.selected false
        end
      end
      if @share_contributors.any?
        f.tab do |t|
          t.label "Page contributors"[:share_page_contributors]
          t.show_tab 'share_population_contributors'
          t.selected false
        end
      end
      if @share_groups.any?
        f.tab do |t|
          t.label "Groups"[:groups]
          t.show_tab 'share_population_my_groups'
          t.selected false
        end
      end
      if @share_networks.any?
        f.tab do |t|
          t.label "Networks"[:networks]
          t.show_tab 'share_population_my_networks'
          t.selected false
        end
      end
      if @share_committees.any?
        f.tab do |t|
          t.label "Committees"[:committees]
          t.show_tab 'share_population_my_committees'
          t.selected false
        end
      end
      if @share_friends.any?
        f.tab do |t|
          t.label "Contacts"[:contacts]
          t.show_tab 'share_population_friends'
          t.selected false
        end
      end
      if @share_peers.any?
        f.tab do |t|
          t.label "Peers"[:peers]
          t.show_tab 'share_population_peers'
          t.selected false
        end
      end
    end
  end

  def share_page_recipient_panes
    setup_sharing_populations
    html = []
    if @share_page_groups.any?
      html << share_recipient_pane('share_population_groups', @share_page_groups)
    end
    if @share_contributors.any?
      html << share_recipient_pane('share_population_contributors', @share_contributors)
    end
    if @share_groups.any?
      html << share_recipient_pane('share_population_my_groups', @share_groups)
    end
    if @share_networks.any?
      html << share_recipient_pane('share_population_my_networks', @share_networks)
    end
    if @share_committees.any?
      html << share_recipient_pane('share_population_my_committees', @share_committees)
    end
    if @share_friends.any?
      html << share_recipient_pane('share_population_friends', @share_friends)
    end
    if @share_peers.any?
      html << share_recipient_pane('share_population_peers', @share_peers)
    end
    #html << share_freeform_recipient_pane()
    html.join("\n")
  end

  def share_page_recipient_results
    setup_sharing_populations
    params[:recipients] ||= {}
    sets = [
      @share_page_groups + @share_groups + @share_networks + @share_committees,
      @share_contributors + @share_friends + @share_peers
    ]
    sets.collect do |set|
      set.sort_by{|e|e.name}.uniq.collect do |entity|
        style = params[:recipients][entity.name] ? '' : 'display:none'
        content_tag(:div, display_entity(entity, :xsmall), :id => entity.name+'_selected', :style=>style)
      end.join("\n")
    end.join("\n")
  end

  def share_recipient_pane(id,objects)
    html = []
    objects.each do |object|
      html << content_tag(
        :label,
        check_box_tag(
          "recipients[#{object.name}]",
          "1", params[:recipients][object.name].any?,
          :onclick => "recipient_checked(this, '#{object.name}');",
          :class => "recipient_checkbox_#{object.name}"
        ) +
        '&nbsp;' + object.display_name
      )
      html << '<br/>'
    end
    content_tag :div, html.join("\n"), :id => id, :style => 'display:none', :class => 'tab_content'
  end

  def share_freeform_recipient_pane()
    content_tag :div, text_area_tag('recipients_text_area', '', :style => 'width:100%', :id => 'recipient_list'), :id => 'share_freeform', :class => 'tab_content', :style => 'display:none'
  end


=end
