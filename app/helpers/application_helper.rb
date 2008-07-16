# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  include PageHelper      # various page helpers needed everywhere
  include UrlHelper       # for user and group urls/links
  include Formy           # helps create forms
  include LayoutHelper    # used in layouts
  include LinkHelper      # for making buttons
  include TimeHelper      # for displaying local and readable times
  include ErrorHelper     # for displaying errors and messages to the user
  include ImageHelper     # icons, avatars, spinners, etc.
  include PathFinder::Options       # for Page.find_by_path options
  include WindowedPaginationHelper  # deprecated, should be using will_paginate

  ## makes this: link | link | link
  def link_line(*links)
    "<div class='link_line'>" + links.compact.join(' | ') + "</div>"
  end

  ## coverts bytes into something more readable 
  def friendly_size(bytes)
    if bytes > 1.megabyte
      '%s MB' % (bytes / 1.megabyte)
    elsif bytes > 1.kilobyte
      '%s KB' % (bytes / 1.kilobyte)
    else
      '%s B' % bytes
    end
  end
  
  def created_modified_date(created, modified=nil)
    return friendly_date(created) unless modified and modified != created
    created_date = friendly_date(created)
    modified_date = friendly_date(modified)
    detail_string = "created:&nbsp;#{created_date}<br/>modified:&nbsp;#{modified_date}"
    link_to_function created_date, %Q[this.replace("#{detail_string}")], :class => 'dotted'
  end
   
  def once?(key)
    @called_before ||= {}
    return false if @called_before[key]
    @called_before[key]=true
  end

  # produces javascript to hide the given id or object
  def hide(id, extra=nil)
    id = dom_id(id,extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').hide();" % id
  end

  # produces javascript to show the given id or object
  def show(id, extra=nil)
    id = dom_id(id,extra) if id.is_a?(ActiveRecord::Base)
    "$('%s').show();" % id
  end
  
  def logged_in_since
    session[:logged_in_since] || Time.now
  end
end
