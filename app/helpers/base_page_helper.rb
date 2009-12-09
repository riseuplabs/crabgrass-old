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
    if may_watch_page?
      existing_watch = (@upart and @upart.watch?) or false
      li_id = 'watch_li'
      checkbox_id = 'watch_checkbox'
      url = {:controller => 'base_page/participation', :action => 'update_watch',
             :add => !existing_watch, :page_id => @page.id}
      checkbox_line = sidebar_checkbox(I18n.t(:watch_checkbox), existing_watch, url, li_id, checkbox_id)
      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
    end
  end

  def share_all_line
    if may_share_with_all?
      li_id = 'share_all_li'
      checkbox_id = 'share_all_checkbox'
      url = {:controller => 'base_page/participation',
        :action => 'update_share_all',
        :page_id => @page.id,
        :add => !@page.shared_with_all?
      }
      checkbox_line = sidebar_checkbox(I18n.t(:share_all_checkbox), @page.shared_with_all?, url, li_id, checkbox_id, :title => I18n.t(:share_all_checkbox_help))
      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
    elsif Site.current.network
      content_tag :li, check_box_tag(checkbox_id, '1', @page.shared_with_all?, :class => 'check', :disabled => true) + " " + content_tag(:span, I18n.t(:share_all_checkbox), :class => 'a'), :class => 'small_icon'
    end
  end

  def public_line
    if may_public_page?
      li_id = 'public_li'
      checkbox_id = 'public_checkbox'
      url = {:controller => 'base_page/participation', :action => 'update_public', :page_id => @page.id, :add => !@page.public?}
      checkbox_line = sidebar_checkbox(I18n.t(:public_checkbox), @page.public?, url, li_id, checkbox_id, :title => I18n.t(:public_checkbox_help))
      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
    else
      content_tag :li, check_box_tag(checkbox_id, '1', @page.public?, :class => 'check', :disabled => true) + " " + content_tag(:span, I18n.t(:public_checkbox), :class => 'a'), :class => 'small_icon'
    end
  end

  def star_line
    if may_star_page?
      li_id = 'star_li'
      if @upart and @upart.star?
        icon = 'star'
        add = false
        label = I18n.t(:remove_star_link, :star_count => @page.stars_count)
      else
        icon = 'star_empty_dark'
        add = true
        label = I18n.t(:add_star_link, :star_count => @page.stars_count)
      end
      url = {:controller => 'base_page/participation', :action => 'update_star',
             :add => add, :page_id => @page.id}
      link = link_to_remote_with_icon(label, :url => url, :icon => icon)
      content_tag :li, link, :id => li_id
    end
  end

  # used in the sidebar of deleted pages
  def undelete_line
    if may_undelete_page?
      link = link_to(I18n.t(:undelete_from_trash),
        {:controller => '/base_page/trash', :page_id => @page.id, :action => 'undelete'},
        :method => 'post'
      )
      content_tag :li, link, :class => 'small_icon refresh_16'
    end
  end

  # used in the sidebar of deleted pages
  def destroy_line
    if may_destroy_page?
      link = link_to_with_confirm(I18n.t(:destroy_page_via_shred), {:confirm => I18n.t(:destroy_confirmation, :thing => I18n.t(:page)), :url => url_for(:controller => '/base_page/trash', :page_id => @page.id, :action => 'destroy')})
      content_tag :li, link, :class => 'small_icon minus_16'
    end
  end

  def view_line
    if @show_print != false
      printable = link_to I18n.t(:print_view_link), page_url(@page, :action => "print")
      content_tag :li, printable, :class => 'small_icon printer_16'
    end
  end

  def history_line
    link = link_to I18n.t(:history), page_url(@page, :action => "page_history")
    content_tag :li, link, :class => 'small_icon table_16'
  end

  ##
  ## SIDEBAR COLLECTIONS
  ##

  def page_attachments
    if @page.assets.any?
      items = @page.assets.collect do |asset|
        link_to_asset(asset, :small, :crop! => '36x36')
      end
      content_tag :div, column_layout(3, items), :class => 'side_indent'
    elsif may_create_assets?
      ''
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
#  def popup_holder_style
#    page_width, page_height = params[:page].split('x')
#    object_x, object_y      = params[:position].split('x')
#    right = page_width.to_i - object_x.to_i
#    top   = object_y.to_i
#    right += 17
#    top -= 32
#    "display: block; right: #{right}px; top: #{top}px;"
#  end

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
    options[:controller] ||= options[:name]
    show_popup = options[:show_popup] || 'show'
    popup_url = url_for({
      :controller => "base_page/#{options.delete(:controller)}",
      :action => show_popup,# 'show',
      :popup => true,
      :page_id => @page.id,
      :name => options.delete(:name)
    })
    #options.merge!(:after_hide => 'afterHide()')
    title = options.delete(:title) || options[:label]
    link_to_modal(options.delete(:label), {:url => popup_url, :title => title}, options)
  end

  # to be included in the popup result for any popup that should refresh the sidebar when it closes.
  # also, set refresh_sidebar to true one the popup_line call
  #def refresh_sidebar_on_close
  #  javascript_tag('afterHide = function(){%s}' % remote_function(:url => {:controller => 'base_page/sidebar', :action => 'refresh', :page_id => @page.id}))
  #end

  # create the <li></li> for a sidebar line that will open a popup when clicked
  def popup_line(options)
    id = options.delete(:id) || options[:name]
    li_id     = "#{id}_li"
    link = show_popup_link(options)
    content_tag :li, link, :id => li_id
  end

  def edit_attachments_line
    if may_show_page?
      popup_line(:name => 'assets', :label => I18n.t(:edit_attachments_link), :icon => 'attach', :title => I18n.t(:edit_attachments))
    end
  end

  def edit_tags_line
    if may_update_tags?
      popup_line(:name => 'tags', :label => I18n.t(:edit_tags_link),
        :title => I18n.t(:edit_tags), :icon => 'tag')
    end
  end

  def share_line
    if may_share_page?
      popup_line(:name => 'share', :label => I18n.t(:share_page_link, :page_class => page_class), :icon => 'group', :controller => 'share')
    end
  end

  def notify_line
    if may_notify_page?
      popup_line(:name => 'notify', :label => I18n.t(:notify_page_link), :icon => 'whistle', :controller => 'share')
    end
  end

  def delete_line
    if may_delete_page?
      popup_line(:name => 'trash', :label => I18n.t(:delete_page_link, :page_class => page_class), :icon => 'trash')
    end
  end

#  def move_line
#    if may_move_page?
#      popup_line(:name => 'move', :label => I18n.t(:move_page_link) % {:page_class => page_class }, :icon => 'lorry', :controller => 'participation')
#    end
#  end

  def details_line(id='details')
    if id == 'details'
      label = I18n.t(:page_details_link, :page_class => page_class)
      icon = 'table'
    elsif id == 'more'
      label = I18n.t(:see_more_link)
      icon = nil
    end

    if may_show_page?
      popup_line(:name => 'details', :id => id, :label => label, :title => I18n.t(:page_details_link, :page_class => page_class), :icon => icon, :controller => 'participation')
    end
  end

  ##
  ## MISC HELPERS
  ##

  def page_class
    @page ? @page.class_display_name.capitalize : @page_class.class_display_name.capitalize
  end

end
