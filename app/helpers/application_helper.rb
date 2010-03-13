# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ##
  ## HTML CONTENT HELPERS
  ##

  def content_tag_if(tag, content, options={})
    if content.any?
      content_tag(tag, content, options)
    end
  end

  def option_empty(label='')
    %(<option value=''>#{label}</option>)
  end

  def format_text(str)
    str.any? ? GreenCloth.new(str).to_html() : ''
  end

  # DROP DOWN LIST
  #
  # use this as:
  #
  # drop_down("Title", {"Option 1" => some_place_path, "Option 2" => "js: alert('hello')"}, optionally_index_for_selected_option)
  #
  # <label for="select_id">Title</label>
  # <select id="select_id">
  #   <option value="/some/place">Option 1</option>
  #   <option value="alert('hello')">Option 2</option>
  # </select>
  #
  # Actions happen on the onchange event
  #
  def drop_down(select_title, items, selected_index = 0)

    select_id = "select_#{select_title.gsub(/[^a-zA-Z]+/, '')}"

    text_label = content_tag(:label, I18n.t(:view_label), :for => select_id) if !select_title.nil? && !select_title.blank?

    current_index = 0
    options = items.map do |title, perform|
      selected = selected_index == current_index ? {:selected => "selected"} : {}
      current_index += 1
      perform = url_for(perform) if perform.is_a?(Hash)
      option_id = "option_#{title.gsub(/[^a-zA-Z]+/, '')}"
      value = drop_down_action(perform)
      content_tag :option, title, {:value => value, :id => option_id}.merge(selected)
    end.join("\n")

    content_tag(:div, text_label + select_tag(select_id, options, :onchange => "javascript: eval(this.options[this.selectedIndex].value)"), :id => "pages_view")
  end

  def drop_down_action(perform)
    if perform.match(/^js\:/)
      perform.gsub(/^js\:/, '')
    else
      "window.location = '#{perform}';"
    end
  end

  ##
  ## LINK HELPERS
  ##

  ## makes this: link | link | link
  def link_line(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:div, links.compact.join(char), :class => 'link_line')
  end

  def link_span(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:span, links.compact.join(char), :class => 'link_line')
  end

  #
  # show link with totals for a collection that belongs to an object
  #

  def totalize_with_link(object, collection, controller=nil, action=nil)
    action ||= 'list'
    controller ||= url_for(:controller => object.class.name.pluralize.underscore, :action => action)
    link_if_may(I18n.t(:total, :count => (collection.size).to_s) ,
                   controller , action, object) or
    I18n.t(:total, :count => (collection.size).to_s)
  end

  def guess_url_for_entity(entity)
    case entity.class.name
    when 'Group' then url_for_group(entity)
    when 'User' then url_for_user(entity)
    end
  end

  ##
  ## GENERAL UTILITY
  ##

  # returns the first of the args where any? returns true
  # if none has any, return last
  def first_with_any(*args)
    for str in args
      return str if str.any?
    end
    return args.last
  end

  ## converts bytes into something more readable
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

  # from http://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end

  def browser_is_ie?
    user_agent = request.env['HTTP_USER_AGENT'].try.downcase
    user_agent =~ /msie/ and user_agent !~ /opera/
  end

  ##
  ## CRABGRASS SPECIFIC
  ##

  def mini_search_form(options={})
    unless params[:action] == 'search' or params[:controller] =~ /search|inbox/
      render :partial => 'pages/mini_search', :locals => options
    end
  end

  def letter_pagination_labels
    $letter_pagination_labels_list ||= ("A".."Z").to_a + ["#"]
  end

  def letter_pagination_links(url_opts = {}, pagination_opts = {}, &url_proc)
    url_proc = method :url_for if url_proc.nil?
    available_letters = pagination_opts[:available_letters]
    if available_letters and !available_letters.grep(/^[^a-z]/i).empty?
      # we have things that are not letters in the mix
      available_letters << "#"
    end

    render  :partial => 'pages/letter_pagination',
                        :locals => {:letter_labels => letter_pagination_labels,
                                    :available_letters => pagination_opts[:available_letters],
                                    :url_proc => url_proc,
                                    :url_opts => url_opts,
                                    }
  end

  #
  # Default pagination link options:
  #
  #   :class        => 'pagination',
  #   :previous_label   => '&laquo; Previous',
  #   :next_label   => 'Next &raquo;',
  #   :inner_window => 4, # links around the current page
  #   :outer_window => 1, # links around beginning and end
  #   :separator    => ' ',
  #   :param_name   => :page,
  #   :params       => nil,
  #   :renderer     => 'WillPaginate::LinkRenderer',
  #   :page_links   => true,
  #   :container    => true
  #
  def pagination_links(things, options={})
    if request.xhr?
      defaults = {:renderer => LinkRenderer::Ajax, :previous_label => I18n.t(:pagination_previous), :next_label => I18n.t(:pagination_next), :inner_window => 2}
    else
      defaults = {:renderer => LinkRenderer::Dispatch, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
    end
    will_paginate(things, defaults.merge(options))
  end

  # *NEWUI
  #
  # Default pagination link options:
  #
  #   :class        => 'pagination',
  #   :previous_label   => '&laquo; Previous',
  #   :next_label   => 'Next &raquo;',
  #   :inner_window => 4, # links around the current page
  #   :outer_window => 1, # links around beginning and end
  #   :separator    => ' ',
  #   :param_name   => :page,
  #   :params       => nil,
  #   :renderer     => 'WillPaginate::LinkRenderer',
  #   :page_links   => true,
  #   :container    => true
  #
  def pagination_for(things, options={})
    return if !things.is_a?(WillPaginate::Collection)
    if request.xhr?
      defaults = {:renderer => LinkRenderer::Ajax, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
    else
      defaults = {:renderer => LinkRenderer::Dispatch, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
    end
    will_paginate(things, defaults.merge(options))
  end

  def options_for_my_groups(selected=nil)
    options_for_select([['','']] + current_user.groups.sort_by{|g|g.name}.to_select(:name), selected)
  end

  def options_for_language(selected=nil)
    selected ||= session[:language_code].to_s
    options_array = I18n.available_locales.collect {|locale| [I18n.language_for_locale(locale).try.name, locale.to_s]}
    options_for_select(options_array, selected)
  end

  def header_with_more(tag, klass, text, more_url=nil)
    span = more_url ? " " + content_tag(:span, "&bull; " + link_to(I18n.t(:see_more_link)+ARROW, more_url)) : ""
    content_tag tag, text + span, :class => klass
  end

  # *NEWUI
  #
  # returns the kind of profile open or closed/private
  #
  def open_or_private(profile)
    if profile.may_see?
      t(:open)
    else
      t(:private)
    end
  end

  # *NEWUI
  #
  # Construct a content tag with a more link
  #
  # :options[:more_url] = the url for more link
  # :options[:length] = the max lenght to display
  # :options[:class] = any html options can be added and will be applied to the tag
  # also you can handle the link manually passing a block
  # text_with_more :p, my_text do
  #   link_to "more", more_path
  # end

  def text_with_more(text, tag='p', options={}, &block)
    length = options.delete(:length) || 50
    omission = options.delete(:omission) || "... "
    if block_given?
      out = truncate(text, :length => length, :omission => omission + capture_haml(&block))
      capture_haml do
        #
        # TODO: update  this with rails 2.3 to:
        # haml_tag tag, options do
        #
        haml_tag tag do
          haml_concat out
        end
      end
    else
      link = link_to(' '+I18n.t(:see_more_link)+ARROW, options.delete(:more_url))
      out = truncate(text, :length => length, :omission => omission + link)
      capture_haml do
        haml_tag(tag, out,  options)
      end
    end
  end

  def expand_links(description)
    description.to_s.gsub(/<span class="(user|group)">(.*?)<\/span>/) do |match|
      case $1
        when "user": link_to_user($2)
        when "group": link_to_group($2)
      end
    end
  end

  def linked_activity_description(activity)
    description = activity.try.safe_description(self)
    expand_links(description)
  end

  def display_activity(activity)
    description = activity.try.safe_description(self)
    return unless description

    description = expand_links(description)

    created_at = (friendly_date(activity.created_at) if activity.created_at)

    more_link = activity.link
    if more_link.is_a? Hash
      more_link = link_to(I18n.t(:details_link) + ARROW, more_link, :class => 'shy')
    end
    more_link = content_tag(:span, [created_at, more_link].combine, :class => 'commands')

    css_class = "small_icon #{activity.icon}_16 shy_parent"
    css_style = activity.style

    content_tag :li, [description, more_link].combine, :class => css_class, :style => css_style
  end

  def side_list_li(options)
     active = url_active?(options[:url]) || options[:active]
     content_tag(:li, link_to_active(options[:text], options[:url], active), :class => "small_icon #{options[:icon]}_16 #{active ? 'active' : ''}")
  end

  def formatting_reference_link
   %Q{<div class='formatting_reference'><a class="small_icon help_16" href="/static/greencloth" onclick="quickRedReference(); return false;">%s</a></div>} % I18n.t(:formatting_reference_link)
  end

  # returns the related help string, but only if it is translated.
  def help(symbol)
    symbol = "#{symbol}_help".to_sym
    text = nil
    begin
      text = I18n.t(symbol)
    rescue I18n::MissingTranslationData
      # this error is only raised in dev/test mode when translation is missing
      return nil
    end

    # return nil if I18n.t can't find the translation (in production mode) and has to humanize it
    text == symbol.to_s.humanize ? nil : text
  end

  def debug_info
    if RAILS_ENV == 'development'
      render :partial => 'layouts/base/debug_info'
    end
  end

  #
  # *NEWUI
  #
  # provides a block for main container
  #
  # content_starts_here do
  #   %h1 my page
  #
  def content_starts_here(&block)
    capture_haml do
      haml_tag :div, :id =>'main-content' do
        haml_concat capture_haml(&block)
      end
    end
  end

  private

  def link_char(links)
    if links.first.is_a? Symbol
      char = links.shift
      return ' &bull; ' if char == :bullet
      return ' ' if char == :none
      return ' | '
    else
      return ' | '
    end
  end

end
