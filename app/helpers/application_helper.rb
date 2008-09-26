# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ## makes this: link | link | link
  def link_line(*links)
    "<div class='link_line'>" + links.compact.join(' | ') + "</div>"
  end

  ## coverts bytes into something more readable 
  def friendly_size(bytes)
    return unless bytes
    if bytes > 1.megabyte
      '%s MB' % (bytes / 1.megabyte)
    elsif bytes > 1.kilobyte
      '%s KB' % (bytes / 1.kilobyte)
    else
      '%s B' % bytes
    end
  end
   
  def once?(key)
    @called_before ||= {}
    return false if @called_before[key]
    @called_before[key]=true
  end
  
  def logged_in_since
    session[:logged_in_since] || Time.now
  end

  def option_empty(label='')
    %(<option value=''>#{label}</option>)
  end

  # from http://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options), block.binding)
  end

  def mini_search_form(options={})
    unless params[:action] == 'search' or params[:controller] =~ /search|inbox/
      render :partial => 'pages/mini_search', :locals => options
    end
  end

  def pagination_links(things, param_name='page')
    will_paginate things, :param_name => param_name, :renderer => DispatchLinkRenderer, :prev_label => "&laquo; %s" % "prev".t, :next_label => "%s &raquo;" % "next".t
  end
  
  def options_for_my_groups(selected=nil)
    options_for_select([['','']] + current_user.groups.sort_by{|g|g.name}.to_select(:name), selected)
  end
  
end
