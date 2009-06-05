=begin

this helper is available to all page controllers derived from
BasePageController

=end

module BasePageHelper

  def header_for_page_create(page_class)
    style = 'background: url(/images/pages/big/#{page_class.icon}) no-repeat 0% 50%'
    text = "<b>#{page_class.class_display_name}</b>: #{page_class.class_description}"
    content_tag(:div, content_tag(:span, text, :style => style, :class => 'page-link'), :class => 'page-class')
  end

  def return_to_page(page)
    content_tag(:p, link_to('&laquo; ' + 'return to'[:return_to] + ' <b>%s</b>' % @page.title, page_url(@page)))
  end
  
  def recipient_checkbox_line(recipient, options={})
    name = CGI.escape(recipient.name) # so that '+' does show up as ' '
    ret = "<label>"
    ret << check_box_tag("recipients[#{name}][send_notice]", 1, false, {:class => options[:class]})
    ret << display_entity(recipient, :avatar => :xsmall, :format => :hover)
    ret << "</label>"
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

  def sidebar_checkbox(text, checked, url, li_id, checkbox_id, options = {})
    click = remote_function(
      :url => url,
      :loading  => hide(checkbox_id) + add_class_name(li_id, 'spinner_icon')
#      :complete => show(checkbox_id) + remove_class_name(li_id, 'spinner_icon')
    )
    out = []
    #out << "<label id='#{checkbox_id}_label'>" # checkbox labels don't work in IE
    out << check_box_tag(checkbox_id, '1', checked, :class => 'check', :onclick => click)
    out << link_to_function(text, click, :class => 'check', :title => options[:title])
    #out << '</label>'
    out.join
  end  

  def popup(title, options = {}, &block)
    style = [options.delete(:style), "width:%s" % options.delete(:width)].compact.join("; ")
    block_to_partial('base_page/popup_template', {:style=>style, :id=>''}.merge(options).merge(:title => title), &block)
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
      checkbox_line = sidebar_checkbox('Public'[:public_checkbox], @page.public?, url, li_id, checkbox_id, :title => "If checked, anyone may view this page."[:public_checkbox_help])
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

  def undelete_line
    if current_user.may?(:admin, @page)
      link = link_to("Undelete :page_class"[:undelete_page_link] % { :page_class => page_class },
                     page_xurl(@page, :controller => 'base_page/trash', :action => 'undelete'),
                     :method => 'post')
      content_tag :li, link, :class => 'small_icon refresh_16'
    end
  end

#  def destroy_line
#    if current_user.may?(:delete, @page)
#      link = link_to("Shred :page_class"[:destroy_page_link] % { :page_class => page_class },
#                     page_xurl(@page, :controller => 'base_page/trash', :action => 'destroy'),
#                     :method => 'post',
#                     :confirm => 'Are you sure you want to destroy this page? It cannot be undeleted.'[:confirm_destroy_page])
#      content_tag :li, link, :class => 'small_icon minus_16'
#    end
#  end

  def view_line
    if @show_print
      printable = link_to "Printable"[:print_view_link], page_url(@page, :action => "print")
      #source = @page.controller.respond_to?(:source) ? page_url(@page, :action=>"source") : nil
      #text = ["View As"[:view_page_as], printable, source].compact.join(' ')
      content_tag :li, printable, :class => 'small_icon printer_16'
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
  # 
  # for the popup to display in the right spot, we actually offset it by
  # top: -32px, right: 43px from the natural position of the clicked element.
  #
  def popup_holder_style
    page_width, page_height = params[:page].split('x')
    object_x, object_y      = params[:position].split('x')
    right = page_width.to_i - object_x.to_i
    top   = object_y.to_i
    right += 43
    top -= 32
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
  # NOTE #2: this is no longer how the right column works. so we should not
  # have to use absolutely positioned popups anymore.
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
      popup_line(:name => 'share', :label => "Share Page"[:share_page_link] % {:page_class => page_class }, :icon => 'group_16', :controller => 'share')
    end
  end

  def notify_line
    if current_user.may? :view, @page
      popup_line(:name => 'notify', :label => "Send Notification"[:notify_page_link] % {:page_class => page_class }, :icon => 'whistle_16', :controller => 'share')
    end
  end
 
  def delete_line
    if current_user.may? :admin, @page
      popup_line(:name => 'trash', :label => "Delete :page_class"[:delete_page_link] % {:page_class => page_class }, :icon => 'trash_16')
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

  def select_page_access(name, options={})
    selected = options[:selected]

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
    @page ? @page.class_display_name.capitalize : @page_class.class_display_name.capitalize
  end
  
  def select_page_owner(_erbout)
    owner_name = @page.owner ? @page.owner.name : ''
    if current_user.may?(:admin, @page)
      form_tag(url_for(:controller => '/base_page/participation', :action => 'set_owner', :page_id => @page.id)) do 
        possibles = @page.admins.to_select('both_names', 'name') + [["(#{"None"[:none]})",""]]
        concat(
          select_tag(
            'owner',
             options_for_select(possibles, owner_name),
            :onchange => 'this.form.submit();'
          ),
          binding
        )
      end
      ""
    elsif @page.owner
      h(@page.owner.both_names)
    else
      "None"[:none]
    end
  end
  
end
