module LayoutHelper

  ##
  ## DISPLAYING BREADCRUMBS and CONTEXT
  ##

  def link_to_breadcrumbs(min_length = 3)
    if @breadcrumbs and @breadcrumbs.length >= min_length
      content_tag(:div, @breadcrumbs.collect{|b| content_tag(:a, b[0], :href => b[1])}.join(' &raquo; '), :class => 'breadcrumb')
    else
      ""
    end
  end

  def first_breadcrumb
    @breadcrumbs.first.first if @breadcrumbs.any?
  end

  ##
  ## TITLE
  ##

  def title_from_context
    (
      [@html_title] +
      (@context||[]).collect{|b|truncate(b[0])}.reverse +
      [current_site.title]
    ).compact.join(' - ')
  end

  ##
  ## STYLESHEET
  ##

  # CustomAppearances model allows administrators to override the default css values
  # this method will link to the appropriate overriden css
  def themed_stylesheet_link_tag(path)
    appearance = (current_site && current_site.custom_appearance) || CustomAppearance.default

    themed_stylesheet_url = appearance.themed_stylesheet_url(path)
    stylesheet_link_tag(themed_stylesheet_url)
  end

  # custom stylesheet
  # rather than include every stylesheet in every request, some stylesheets are
  # only included if they are needed. See Application#stylesheet()
  def optional_stylesheet_tag
    stylesheet = controller.class.stylesheet || {}
    sheets = [stylesheet[:all], @stylesheet, stylesheet[params[:action].to_sym]].flatten.compact.collect{|i| "as_needed/#{i}"}
    sheets.collect {|s| themed_stylesheet_link_tag(s)}
  end

  # crabgrass_stylesheets()
  # this is the main helper that is in charge of returning all the needed style
  # elements for HTML>HEAD. There are five (5!) types of stylings:
  #
  # (1) default crabgrass stylesheets (for core things like layout)
  # (2) theme_styles (core css, but for making things pretty).
  # (3) optional stylesheets (these are stylesheets that are loaded on a
  #     per-controller or per-action basis.
  # (4) context styles (style changes based on context)
  # (5) content_for :style (inline styles set in the views)
  # (6) mod styles (so that mods can insert their own styles after everthing else)

  def crabgrass_stylesheets
    lines = []

    lines << themed_stylesheet_link_tag('screen.css')
    lines << stylesheet_link_tag('icon_png')
    lines << optional_stylesheet_tag
    lines << '<style type="text/css">'
    #lines << context_styles
    lines << @content_for_style
    lines << '</style>'
    lines << '<!--[if IE 6]>'
    lines << stylesheet_link_tag('ie/ie6')
    lines << stylesheet_link_tag('icon_gif')
    lines << '<![endif]-->'
    lines << '<!--[if IE 7]>'
    lines << stylesheet_link_tag('ie/ie7')
    lines << stylesheet_link_tag('icon_gif')
    lines << '<![endif]-->'
    if language_direction == "rtl"
      lines << themed_stylesheet_link_tag('rtl')
    end
    lines.join("\n")
  end

  def favicon_link
    icon_urls = if current_appearance and current_appearance.favicon
      [current_appearance.favicon.url] * 2
    else
      ['/favicon.ico', '/favicon.png']
    end

    %Q[<link rel="shortcut icon" href="#{icon_urls[0]}" type="image/x-icon" />
  <link rel="icon" href="#{icon_urls[1]}" type="image/x-icon" />]
  end

  def type_of_column_layout
    @layout_type ||= if @left_column.any? and @right_column.any?
      'three'
    elsif !@left_column.any? and !@right_column.any?
      'one'
    elsif @left_column.any?
      'left'
    elsif @right_column.any?
      'right'
    end
  end

  def language_direction
    @language_direction ||= if I18n.language_for_locale(session[:language_code]).try.rtl
      "rtl"
    else
      "ltr"
    end
  end

  ##
  ## JAVASCRIPT
  ##

  # Core js that we always need.
  # Currently, effects.js and controls.js are required for autocomplete.js.
  # However, autocomplete uses very little of the controls.js code, which in turn
  # should not need the effects.js at all. So, with a little effort, effects and
  # controls could be moved to extra.
  MAIN_JS = {:main => ['prototype', 'application', 'modalbox', 'effects', 'controls', 'autocomplete']}

  # extra js that we might sometimes need
  EXTRA_JS = {:extra => ['dragdrop', 'builder', 'slider']}

  # needed whenever we want controls for editing a wiki
  WIKI_JS = {:wiki => ['wiki/html_editor', 'wiki/textile_editor', 'wiki/wiki_editing', 'wiki/xinha/XinhaCore']}

  JS_BUNDLES = [MAIN_JS, EXTRA_JS, WIKI_JS]

  JS_BUNDLE_LOAD_ORDER = JS_BUNDLES.collect{|b|b.keys.first}

  # eg: {:main => [...], :extra => [...]}
  JS_BUNDLES_COMBINED = JS_BUNDLES.inject({}){|a,b|a.merge(b)}

  # eg: {'dragdrop' => :extra, 'modalbox' => :main, ...}
  JS_BUNDLE_MAP = Hash[*JS_BUNDLES_COMBINED.collect{|k,v|v.collect{|u|[u,k]}}.flatten]

  # Includes the correct javascript tags for the current request.
  # See ApplicationController#javascript for details.
  #
  # In brief: the correct javascript is loaded for a particular controller and a
  # particular action. Some javascripts are defined in bundles. A bundle gets
  # activated if called by name (ie :extra) or if a file in the bundle is
  # included (ie 'dragdrop')
  def javascript_include_tags
    scripts = controller.class.javascript || {}
    files = [:main, scripts[:all], scripts[params[:action].to_sym]].flatten.compact
    return unless files.any?

    bundles = {}
    as_needed = {}
    includes = []

    files.each do |file|
      if JS_BUNDLE_MAP[file.to_s]                    # if a file in a bundle is specified
        bundles[JS_BUNDLE_MAP[file.to_s]] = true     # include the whole bundle
      elsif JS_BUNDLES_COMBINED[file.to_sym]         # if a bundle symbol is specified
        bundles[file.to_sym] = true                  # include the whole bundle
      else
        as_needed["as_needed/#{file}"] = true        # otherwise, include one file.
      end
    end

    bundles = JS_BUNDLE_LOAD_ORDER & bundles.keys    # sort the bundles
    bundles.each do |bundle|
      args = JS_BUNDLES_COMBINED[bundle] + [{:cache => bundle.to_s}]  # ie ['dragdrop', 'builder', {:cache => 'extra'}]
      includes << javascript_include_tag(*args)
    end
    if as_needed.any?
      includes << javascript_include_tag(*as_needed.keys)
    end
    return includes
  end

  def crabgrass_javascripts
    lines = javascript_include_tags
    lines << '<script type="text/javascript">'
    lines << @content_for_script
    lines << localize_modalbox_strings
    lines << '</script>'
    lines << '<!--[if lt IE 7.]>'
      # make 24-bit pngs work in ie6
      lines << '<script defer type="text/javascript" src="/javascripts/ie/pngfix.js"></script>'
      # prevent flicker on background images in ie6
      lines << '<script>try {document.execCommand("BackgroundImageCache", false, true);} catch(err) {}</script>'
    lines << '<![endif]-->'
    # run firebug lite in dev mode for ie
    if false and RAILS_ENV == 'development'
      lines << '<!--[if IE]>'
      lines << "<script type='text/javascript' src='http://getfirebug.com/releases/lite/1.2/firebug-lite-compressed.js'></script>"
      lines << '<![endif]-->'
    end
    lines.join("\n")
  end

  ##
  ## BANNER
  ##

  # banner stuff
  def banner_style
    "background: #{@banner_style.background_color}; color: #{@banner_style.color};" if @banner_style
  end
  def banner_background
    @banner_style.background_color if @banner_style
  end
  def banner_foreground
    @banner_style.color if @banner_style
  end

  ##
  ## CONTEXT STYLES
  ##

  def background_color
    "#ccc"
  end
  def background
    #'url(/images/test/grey-to-light-grey.jpg) repeat-x;'
    'url(/images/background/grey.png) repeat-x;'
  end

  # return all the custom css which might apply just to this one group
  def context_styles
    style = []
     if @banner
       style << '#banner {%s}' % banner_style
       style << '#banner a.name_link {color: %s; text-decoration: none;}' %
                banner_foreground
       style << '#topmenu li.selected span a {background: %s; color: %s}' %
                [banner_background, banner_foreground]
     end
    style.join("\n")
  end

  ##
  ## LAYOUT STRUCTURE
  ##

  # builds and populates a table with the specified number of columns
  def column_layout(cols, items, options = {}, &block)
    lines = []
    count = items.size
    rows = (count.to_f / cols).ceil
    if options[:balanced]
      width= (100.to_f/cols.to_f).to_i
    end
    lines << "<table class='#{options[:class]}'>" unless options[:skip_table_tag]
    if options[:header]
      lines << options[:header]
    end
    for r in 1..rows
      lines << ' <tr>'
      for c in 1..cols
         cell = ((r-1)*cols)+(c-1)
         next unless items[cell]
         lines << "  <td valign='top' #{"style='width:#{width}%'" if options[:balanced]}>"
         if block
           lines << yield(items[cell])
         else
           lines << '  %s' % items[cell]
         end
         #lines << "r%s c%s i%s" % [r,c,cell]
         lines << '  </td>'
      end
      lines << ' </tr>'
    end
    lines << '</table>' unless options[:skip_table_tag]
    lines.join("\n")
  end

  ##
  ## PARTIALS
  ##

  def dialog_page(options = {}, &block)
    block_to_partial('common/dialog_page', options, &block)
  end


  ##
  ## CUSTOMIZED STUFF
  ##

  # build a masthead, using a custom image if available
  def custom_masthead_site_title
    appearance = current_site.custom_appearance
    if appearance and appearance.masthead_asset
      # use an image
      content_tag :div, :id => 'site_logo_wrapper' do
        content_tag :a, :href => '/', :alt => current_site.title do
          image_tag(appearance.masthead_asset.url, :id => 'site_logo')
        end
      end
    else
      # no image
      content_tag :h1, current_site.title, :id => 'site_title'
      # <h1 id='site_title'><%= current_site.title %></h1>
    end
  end

end
