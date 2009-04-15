=begin

this helper is available to all page controllers derived from
BasePageController

=end

module BasePageHelper

  def header_for_page_create(page_class)
    style = 'background: url(/images/pages/big/#{page_class.icon}) no-repeat 0% 50%'
    text = "<b>#{page_class.class_display_name.t}</b>: #{page_class.class_description.t}"
    content_tag(:div, content_tag(:span, text, :style => style, :class => 'page-link'), :class => 'page-class')
  end

  def return_to_page(page)
    content_tag(:p, link_to('&laquo; ' + 'return to'[:return_to] + ' <b>%s</b>' % @page.title, page_url(@page)))
  end
  
  def link_to_user_participation(upart)
    klass = case upart.access_sym
      when :admin : 'tiny_wrench_16'
      when :edit : 'tiny_pencil_16'
      when :view : ''
    end
    label = content_tag :span, upart.user.display_name, :class => klass
    link_to_user(upart.user, :avatar => 'xsmall', :label => label, :style => '')
  end

  def link_to_group_participation(gpart)
    klass = case gpart.access_sym
      when :admin : 'tiny_wrench_16'
      when :edit : 'tiny_pencil_16'
      when :view : ''
    end
    label = content_tag :span, gpart.group.display_name, :class => klass
    link_to_group(gpart.group, :avatar => 'xsmall', :label => label, :style => '')
  end

  ## POSTS HELPERS
  ## (posts are handled by a seperate controller, but all the views for
  ##  posts use this helper)
  ##
  
  def created_modified_date(created, modified=nil)
    return friendly_date(created) unless modified and (modified > created + 30.minutes)
    created_date = friendly_date(created)
    modified_date = friendly_date(modified)
    detail_string = "created:&nbsp;#{created_date}<br/>modified:&nbsp;#{modified_date}"
    link_to_function created_date, %Q[this.replace("#{detail_string}")], :class => 'dotted'
  end

  ##
  ## SIDEBAR HELPERS
  ##

  def sidebar_checkbox(text, checked, url, li_id, checkbox_id)
    click = remote_function(
      :url => url,
      :loading  => hide(checkbox_id) + add_class_name(li_id, 'spinner_icon')
#      :complete => show(checkbox_id) + remove_class_name(li_id, 'spinner_icon')
    )
    out = []
    #out << "<label id='#{checkbox_id}_label'>" # checkbox labels don't work in IE
    out << check_box_tag(checkbox_id, '1', checked, :class => 'check', :onclick => click)
    out << link_to_function(text, click, :class => 'check')
    #out << '</label>'
    out.join
  end  

  def popup(title, options = {}, &block)
    block_to_partial('base_page/popup_template', {:style=>'', :id=>'', :width=>''}.merge(options).merge(:title => title), &block)
  end

  ##
  ## SIDEBAR LINES
  ## 

  def watch_line
    watch = (@upart and @upart.watch?) or false
    li_id = 'watch_li' 
    checkbox_id = 'watch_checkbox'
    action =  watch ? 'remove_watch' : 'add_watch'
    url = {:controller => 'base_page/participation', :action => action, :page_id => @page.id}
    checkbox_line = sidebar_checkbox('Watch For Updates'[:watch_checkbox], watch, url, li_id, checkbox_id)
    content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
  end

  def public_line
    if current_user.may?(:admin, @page)
      li_id = 'public_li' 
      checkbox_id = 'public_checkbox'
      url = {:controller => 'base_page/participation', :action => 'update_public', :page_id => @page.id, :public => (!@page.public?).to_s}
      checkbox_line = sidebar_checkbox('Public'[:public_checkbox], @page.public?, url, li_id, checkbox_id)
      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
    end
  end

  def star_line
    if @upart and @upart.star?
      icon = 'star_16'
      link_action = 'remove_star'
      link_text = 'Remove Star (:star_count)'[:remove_star_link]
    else
      icon = 'star_empty_dark_16'
      link_action = 'add_star'
      link_text = 'Add Star (:star_count)'[:add_star_link]
    end
    link = link_to(link_text % {:star_count => @page.stars},
      {:controller => 'base_page/participation',
        :action => link_action, :page_id => @page.id},
      :method => 'post')
    content_tag :li, link, :class => "small_icon #{icon}"
  end

  def destroy_page_line
    if current_user.may?(:delete, @page)
      link = link_to("Delete :page_class"[:delete_page_link] % { :page_class => page_class },
        page_xurl(@page, :action => 'destroy'),
        :method => 'post', :confirm => 'Are you sure you want to delete this page?')
      content_tag :li, link, :class => 'small_icon trash_16'
    end
  end

  ##
  ## SIDEBAR COLLECTIONS
  ##

  def page_tags
    if @page.tags.any?
      links = @page.tags.collect do |tag|
        tag_link(tag, @page.group_name, @page.created_by_login)
      end.join("\n")
      content_tag :div, links, :class => 'tags'
    elsif current_user.may? :edit, @page
      ''
    end
  end

  def page_attachments
    if @page.assets.any?
      items = @page.assets.collect do |asset|
        link_to_asset(asset, :small, :crop! => '36x36')
      end
      content_tag :div, column_layout(3, items), :class => 'side_indent'
    end
  end


  ##
  ## SIDEBAR POPUP LINES
  ## 

  # used by ajax show_popup.rjs templates
  def popup_holder_style
    page_width, page_height = params[:page].split('x')
    object_x, object_y      = params[:position].split('x')
    right = page_width.to_i - object_x.to_i
    top   = object_y.to_i
    "display: block; right: #{right}px; top: #{top}px;"
  end

  # creates a <a> tag with an ajax link to show a sidebar popup
  # and change the icon of the enclosing <li> to be spinning
  # required options:
  #  :label -- the text to show
  #  :icon  -- class of the icon for the <li>
  #  :name  -- the name of the popup
  # optional:
  #  :controller -- controller to call show_popup on
  #
  # NOTE: before you change the wacky way this works, be warned of this...
  # The right column has overflow:hidden set. This means that the popup
  # cannot be in the right column, or when it appears the window will not
  # get bigger to show the whole popup, but it will just get clipped. 
  # overflow:hidden is required for holygrail layout to work in ie.
  # hence, absolutePositionParams()...  :(
  #
  def show_popup_link(options)
    li_id = options[:name] + '_li'
    options[:controller] ||= options[:name]
    link_to_remote(
      options[:label],
      :url => {
        :controller => "base_page/#{options[:controller]}",
        :action => 'show_popup',
        :page_id => @page.id,
        :name => options[:name]
       },
      :with => "absolutePositionParams(this)",
      :loading => replace_class_name(li_id, options[:icon], 'spinner_icon'),
      :complete => replace_class_name(li_id, 'spinner_icon', options[:icon])
    )
  end

  # create the <li></li> for a sidebar line that will open a popup when clicked
  def popup_line(options)
    name = options[:name]
    li_id     = "#{name}_li"
    #holder_id = "#{name}_holder"
    link = show_popup_link(options)
    #link = %(<div id="#{holder_id}" class="popup_holder"></div>) + link
    content_tag :li, link, :class => "small_icon #{options[:icon]}", :id => li_id
  end

  def edit_attachments_line
    if current_user.may? :edit, @page
      popup_line(:name => 'assets', :label => 'edit'[:edit_attachments_link], :icon => 'attach_16')
    end 
  end

  def edit_tags_line
    if current_user.may? :edit, @page
      popup_line(:name => 'tags', :label => 'edit'[:edit_tags_link], :icon => 'tag_16')
    end
  end

  def share_line
    if current_user.may? :view, @page
      popup_line(:name => 'share', :label => "Share :page_class"[:share_page_link] % {:page_class => page_class }, :icon => 'group_16', :controller => 'participation')
    end
  end

  def move_line
    if current_user.may? :delete, @page
      popup_line(:name => 'move', :label => "Move :page_class"[:move_page_link] % {:page_class => page_class }, :icon => 'lorry_16', :controller => 'participation')
    end
  end

  def details_line
     popup_line(:name => 'details', :label => ":page_class Details"[:page_details_link] % {:page_class => page_class }, :icon => 'table_16', :controller => 'participation')
  end

  ##
  ## PAGE SHARING FORM
  ##

  def setup_sharing_populations
    if @share_groups.nil?
      @share_page_groups    = @page ? @page.namespace_groups : []
      @share_contributors   = @page ? @page.contributors : []
      all_groups = current_user.all_groups.sort_by {|g|g.name}
      @share_groups      = current_user.all_groups.on(current_site).select {|g|g.normal?}
      @share_networks    = current_user.all_groups.on(current_site).select {|g|g.network?}
      @share_committees  = current_user.all_groups.committees_on(current_site)
      @share_friends     = User.contacts_of(current_user).on(current_site).sort_by{|u|u.name}
      @share_peers       = User.peers_of(current_user).on(current_site).sort_by{|u|u.name}

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

  def select_page_access(name, options={})
    selected = params[name]
    options = {:blank => true, :expand => false}.merge(options)
    select_options = [['Coordinator'[:coordinator],'admin'],['Participant'[:participant],'edit'],['Viewer'[:viewer],'view']]
    if options[:blank]
      select_options = [['(' + 'no change'[:no_change] + ')','']] + select_options
      selected ||= ''
    else
      selected ||= 'admin'
    end
    if options[:expand]
      select_tag name, options_for_select(select_options, selected), :size => select_options.size
    else
      select_tag name, options_for_select(select_options, selected)
    end
  end

  def page_class
    @page.class_display_name.t.capitalize
  end
  
  def select_page_owner(_erbout)
    owner_name = @page.owner ? @page.owner.name : ''
    if current_user.may?(:admin, @page)
      form_tag(url_for(:controller => '/base_page/participation', :action => 'set_owner', :page_id => @page.id)) do 
        concat(
          select_tag('owner', options_for_select(@page.admins.to_select('both_names', 'name'), owner_name), :onchange => 'this.form.submit();'),
          binding
        )
      end
      ""
    elsif @page.owner
      h(@page.owner.both_names)
    else
      "none"[:none]
    end
  end
  
end
