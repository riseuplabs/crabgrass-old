# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_char(links)
    if links.first.is_a? Symbol
      char = links.shift
      return ' &bull; ' if char == :bullet
      return ' | '
    else
      return ' | '
    end
  end

  ## makes this: link | link | link
  def link_line(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:div, links.compact.join(char), :class => 'link_line')
  end
  def link_span(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:span, links.compact.join(char), :class => 'link_line')
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
    will_paginate things, :param_name => param_name, :renderer => DispatchLinkRenderer, :prev_label => "&laquo; %s" % "prev"[:pagination_previous], :next_label => "%s &raquo;" % "next"[:pagination_next]
  end
  
  def options_for_my_groups(selected=nil)
    options_for_select([['','']] + current_user.groups.sort_by{|g|g.name}.to_select(:name), selected)
  end
  
  def options_for_language(selected=nil)
    selected ||= session[:language_code].to_s
    options_for_select(LANGUAGES.to_select(:name, :code), selected)
  end

  def header_with_more(tag, klass, text, more_url=nil)
    span = more_url ? " " + content_tag(:span, "&bull; " + link_to('more'[:see_more_link]+ARROW, more_url)) : ""
    content_tag tag, text + span, :class => klass
  end

  # converts span tags from a model (request or activity) and inserts links
  def expand_links(text)
    text.gsub(/<span class="user">(.*?)<\/span>/) do |match|
      link_to_user($1)
    end.gsub(/<span class="group">(.*?)<\/span>/) do |match|
      link_to_group($1)
    end
  end

  def side_list_li(options)
     active = url_active?(options[:url]) || options[:active]
     content_tag(:li, link_to_active(options[:text], options[:url], active), :class => "small_icon #{options[:icon]}_16 #{active ? 'active' : ''}")
  end

end
