# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  include PageHelper       # various page helpers needed everywhere
  include UrlHelper        # for user and group urls/links
  include Formy            # helps create forms
  include LayoutHelper     # used in layouts
  include LinkHelper       # for making buttons
  include TimeHelper       # for displaying local and readable times
  include ErrorHelper      # for displaying errors and messages to the user
  include ImageHelper      # icons, avatars, spinners, etc.
  include JavascriptHelper # helpers that produce javascript
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

end
