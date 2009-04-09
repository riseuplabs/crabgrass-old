module BasePage::ShareHelper




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
    content_tag :div, html.join("\n"), :id => id, :style => 'display:none', :class => 'tab-content'
  end

  def share_freeform_recipient_pane()
    content_tag :div, text_area_tag('recipients_text_area', '', :style => 'width:100%', :id => 'recipient_list'), :id => 'share_freeform', :class => 'tab-content', :style => 'display:none'
  end


=end
