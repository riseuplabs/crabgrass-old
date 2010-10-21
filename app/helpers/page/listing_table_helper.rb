##
## Helpers for page lists in "table" style (ie in a table of columns and rows).
## 
## The idea here is to allow the columns to be displayed in any order. 
##

module Page::ListingTableHelper

  protected

  #
  # page_table_row: display a single row of a page table
  #

  def page_table_row(page, columns, participation=nil)
    # i have commented out the user participation stuff for now, because i think how
    # that works will change.
    #participation ||= page.flag[:user_participation]
    #unread = (participation && !participation.viewed?)
    #participation ||= page.flag[:group_participation]
    unread = false

    trs = []
    tds = []
    tds << content_tag(:td, page_list_cell(page,columns[0], participation), :class=>'first')
    columns[1..-2].each do |column|
      tds << content_tag(:td, page_list_cell(page,column, participation))
    end
    tds << content_tag(:td, page_list_cell(page,columns[-1], participation), :class=>'last')
    trs << content_tag(:tr, tds.join("\n"), (unread ? {:class =>  'unread'}:{}))

    #if participation and participation.is_a? UserParticipation and participation.notice
    #  participation.notice.each do |notice|
    #    next unless notice.is_a? Hash
    #    trs << page_notice_row(notice, columns.size)
    #  end
    #end

    # commenting out excerpt for now, because i think excerpts would look better in another
    # type of page listing.
    #if page.flag[:excerpt]
    #  trs << content_tag(:tr, content_tag(:td,'&nbsp;') + content_tag(:td, escape_excerpt(page.flag[:excerpt]), :class => 'excerpt', :colspan=>columns.size))
    #end
    trs.join("\n")
  end

  def page_table_header_row(columns, options={})
    tds = []
    columns[0..-2].each do |column|
      tds << page_table_header_cell(column, :sortable => options[:sortable])
    end
    tds << page_table_header_cell(columns[-1], :sortable => options[:sortable], :class => 'last')
    content_tag(:tr, tds.join("\n"))
  end

  ##
  ## PRIVATE
  ##
 
  private

  #
  # page_list_cell: emits a single cell in a table
  #
  def page_list_cell(page, column, participation=nil)
    if column == :icon
      page_icon(page)
    elsif column == :checkbox
      check_box('page_checked', page.id, {:class => 'page_check'}, 'checked', '')
    elsif column == :admin_checkbox
      if current_user.may? :admin, page
        check_box('page_checked', page.id, {:class => 'page_check'}, 'checked', '')
      else
        "&nbsp"
      end
    elsif column == :title
      page_list_cell_title(page, column, participation)
    elsif column == :updated_by or column == :updated_by_login
      page.updated_by_login ? link_to_user(page.updated_by_login) : '&nbsp;'
    elsif column == :created_by or column == :created_by_login
      page.created_by_login ? link_to_user(page.created_by_login) : '&nbsp;'
    elsif column == :deleted_by or column == :deleted_by_login
      page.updated_by_login ? link_to_user(page.updated_by_login) : '&nbsp;'
    elsif column == :updated_at
      friendly_date(page.updated_at)
    elsif column == :created_at
      friendly_date(page.created_at)
    elsif column == :deleted_at
      friendly_date(page.updated_at)
    elsif column == :happens_at
      friendly_date(page.happens_at)
    elsif column == :contributors_count or column == :contributors
      page.contributors_count
    elsif column == :stars_count or column == :stars
      if page.stars_count > 0
        content_tag(:span, "%s %s" % [icon_tag('star'), page.stars_count], :class => 'star')
      else
        icon_tag('star_empty')
      end
    elsif column == :views or column == :views_count
      page.views_count
    elsif column == :owner
      page.owner_name
    elsif column == :owner_with_icon
      page_list_cell_owner_with_icon(page)
    elsif column == :last_updated
      page_list_cell_updated_or_created(page)
    elsif column == :contribution
      page_list_cell_contribution(page)
    elsif column == :posts
      page.posts_count
    elsif column == :last_post
      if page.discussion
        content_tag :span, "%s &bull; %s &bull; %s" % [friendly_date(page.discussion.replied_at), link_to_user(page.discussion.replied_by), link_to(I18n.t(:view_posts_link), page_url(page)+"posts-#{page.discussion.last_post_id}")]
      end
    else
      page.send(column)
    end
  end

    #
  # page_table_header_row: emits the header row.
  #
  def page_table_header_cell(column, options={})
    content = if column == :icon or column == :checkbox or column == :admin_checkbox or column == :discuss
      "&nbsp;" # empty <th>s contain an nbsp to prevent collapsing in IE
    elsif column == :updated_by or column == :updated_by_login
      link_to_sort_by I18n.t(:page_list_heading_updated_by), 'updated_by_login', options
    elsif column == :created_by or column == :created_by_login
      link_to_sort_by I18n.t(:page_list_heading_created_by), 'created_by_login', options
    elsif column == :deleted_by or column == :deleted_by_login
      link_to_sort_by I18n.t(:page_list_heading_deleted_by), 'updated_by_login', options
    elsif column == :updated_at
      link_to_sort_by I18n.t(:page_list_heading_updated), 'updated_at', options
    elsif column == :created_at
      link_to_sort_by I18n.t(:page_list_heading_created), 'created_at', options
    elsif column == :deleted_at
      link_to_sort_by I18n.t(:page_list_heading_deleted), 'updated_at', options
    elsif column == :posts
      link_to_sort_by I18n.t(:page_list_heading_posts), 'posts_count', options
    elsif column == :happens_at
      link_to_sort_by I18n.t(:page_list_heading_happens), 'happens_at', options
    elsif column == :contributors_count or column == :contributors
      link_to_sort_by image_tag('ui/person-dark.png'), 'contributors_count', options
    elsif column == :last_post
      link_to_sort_by I18n.t(:page_list_heading_last_post), 'updated_at', options
    elsif column == :stars or column == :stars_count
      link_to_sort_by I18n.t(:page_list_heading_stars), 'stars_count', options
    elsif column == :views or column == :views_count
      link_to_sort_by I18n.t(:page_list_heading_views), 'views', options
    elsif column == :owner_with_icon || column == :owner
      link_to_sort_by I18n.t(:page_list_heading_owner), 'owner_name', options
    elsif column == :last_updated
      link_to_sort_by I18n.t(:page_list_heading_last_updated), 'updated_at', options
    elsif column == :contribution
       link_to_sort_by I18n.t(:page_list_heading_contribution), 'updated_at', options
    elsif column
      link_to_sort_by I18n.t(column.to_sym, :default => column.to_s), column.to_s, options
    end

    content_tag(:th, content)
  end

  # currently disabling sorting, because it is complex. it nice, but complex.
  #  SORTABLE_COLUMNS = %w(
  #    created_at created_by_login updated_at updated_by_login deleted_at deleted_by_login
  #    owner_name title posts_count contributors_count stars_count
  #  ).freeze

  #
  # link_to_sort_by -- emits a single heading cell.
  # option defaults:
  #   :selected => false
  #   :sortable => false

  def link_to_sort_by(text, action, options={})
    text
#    options = {:selected => false, :sortable => false}.merge(options)
#
#    unless options[:sortable] and SORTABLE_COLUMNS.include?(action)
#      return content_tag(:th, text, :class => options[:class])
#    end
#
#    selected = false
#    arrow = ''
#    if @path.sort_arg?(action)
#      selected = true
#      if @path.keyword?('ascending')
#        link = page_path_link(text,"descending/#{action}")
#        arrow = icon_tag('sort_up')
#      else
#        link = page_path_link(text,"ascending/#{action}")
#        arrow = icon_tag('sort_down')
#      end
#    elsif %w(title created_by_login updated_by_login).include? action
#      link = page_path_link(text, "ascending/#{action}")
#      selected = options[:selected]
#    else
#      link = page_path_link(text, "descending/#{action}")
#      selected = options[:selected]
#    end
#    content_tag :th, "#{link} #{arrow}", :class => "#{selected ? 'selected' : ''} #{options[:class]} nowrap"
  end


  ##
  ## TODO: move to listing_helper.rb if any of these are useful in other places.
  ##

  def page_list_cell_owner_with_icon(page)
    return unless page.owner
    if page.owner_type == "Group"
      return link_to_group(page.owner, :avatar => 'xsmall')
    else
      return link_to_user(page.owner, :avatar => 'xsmall')
    end
  end

  def page_list_cell_updated_or_created(page, options={})
    options[:type] ||= :twolines
    field    = (page.updated_at > page.created_at + 1.hour) ? 'updated_at' : 'created_at'
    label    = field == 'updated_at' ? content_tag(:span, I18n.t(:page_list_heading_updated)) : content_tag(:span, I18n.t(:page_list_heading_new), :class=>'new')
    username = link_to_user(page.updated_by_login)
    date     = friendly_date(page.send(field))
    separator = options[:type]==:twolines ? '<br/>' : '&bull;'
    content_tag :span, "%s %s %s &bull; %s" % [username, separator, label, date], :class => 'nowrap'
  end

  def page_list_cell_contribution(page)
     field    = (page.updated_at > page.created_at + 1.minute) ? 'updated_at' : 'created_at'
     label    = field == 'updated_at' ? content_tag(:span, I18n.t(:page_list_heading_updated)) : content_tag(:span, I18n.t(:page_list_heading_new), :class=>'new')
     username = link_to_user(page.updated_by_login)
     date     = friendly_date(page.send(field))
     content_tag :span, "%s <br/> %s &bull; %s" % [username, label, date], :class => 'nowrap'
   end

  def page_list_cell_title(page, column, participation = nil)
    title = link_to(h(page.title), page_url(page))
    if participation and participation.instance_of? UserParticipation
      title += " " + icon_tag("tiny_star") if participation.star?
    end
    if page.flag[:new]
      title += " <span class='newpage'>#{I18n.t(:page_list_heading_new)}</span>"
    end
    return title
  end

  def page_list_cell_posts_count(page)
    if page.posts_count > 1
      # i am not sure if this is very kosher in other languages:
      "%s %s" % [page.posts_count, I18n.t(:page_list_heading_posts)]
    end
  end

end

