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
    label = content_tag :span, upart.user.display_name, :class => upart.access_sym
    link_to_user(upart.user, :avatar => 'xsmall', :label => label, :style => '')
  end

  def link_to_group_participation(gpart)
    label = content_tag :span, gpart.group.display_name, :class => gpart.access_sym
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
    checkbox_line = sidebar_checkbox('watch for updates', watch, url, li_id, checkbox_id)
    content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
  end

  def public_line
    if current_user.may?(:admin, @page)
      li_id = 'public_li' 
      checkbox_id = 'public_checkbox'
      url = {:controller => 'base_page/participation', :action => 'update_public', :page_id => @page.id, :public => (!@page.public?).to_s}
      checkbox_line = sidebar_checkbox('public', @page.public?, url, li_id, checkbox_id)
      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
    end
  end

  def star_line
    if @upart and @upart.star?
      icon = 'full_star_icon'
      link = link_to('remove star', {:controller => 'base_page/participation',
        :action => 'remove_star', :page_id => @page.id}, :method => 'post')
    else
      icon = 'empty_star_icon'
      link = link_to('add star', {:controller => 'base_page/participation', 
        :action => 'add_star', :page_id => @page.id}, :method => 'post')
    end
    content_tag :li, link, :class => "small_icon #{icon}"
  end

  def destroy_page_line
    if current_user.may?(:admin, @page)
      link = link_to('delete page', page_xurl(@page, :action => 'destroy'),
        :method => 'post', :confirm => 'Are you sure you want to delete this page?')
      content_tag :li, link, :class => 'small_icon delete_icon'
    end
  end

  ##
  ## SIDEBAR COLLECTIONS
  ##

  def page_tags
    if @page.tags.any?
      links = @page.tags.collect do |tag|
        tag_link(tag, @page.group_name, @page.created_by_login)
      end.join(", ")
      content_tag :div, links, :class => 'side_indent'
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
      popup_line(:name => 'assets', :label => 'edit', :icon => 'attach_icon')
    end 
  end

  def edit_tags_line
    if current_user.may? :edit, @page
      popup_line(:name => 'tags', :label => 'edit', :icon => 'tag_icon')
    end
  end

  def share_line
    if current_user.may? :view, @page
      popup_line(:name => 'share', :label => 'share page', :icon => 'share_icon', :controller => 'participation')
    end
  end

  def move_line
    if current_user.may? :admin, @page
      popup_line(:name => 'move', :label => 'move page', :icon => 'move_icon', :controller => 'participation')
    end
  end

  def details_line
     popup_line(:name => 'details', :label => 'details', :icon => 'details_icon', :controller => 'participation')
  end


end
