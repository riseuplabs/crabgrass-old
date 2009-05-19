module LayoutHelper

  ##########################################
  # DISPLAYING BREADCRUMBS and CONTEXT
  
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

  #########################################
  # TITLE
  
  def title_from_context
    (
      [@html_title] +
      (@context||[]).collect{|b|truncate(b[0])}.reverse +
      [current_site.title]
    ).compact.join(' - ')
  end
      
  ###########################################
  # STYLESHEET
  
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

  # support for holygrail layout:
  
  # returns the style elements need in the <head> for the holygrail layouts. 
  def holygrail_stylesheets
    lines = []
    lines << stylesheet_link_tag('holygrail/common')
    lines << stylesheet_link_tag('holygrail/' + type_of_column_layout)
    lines << '<!--[if lt IE 7]>
<style media="screen" type="text/css">.col1 {width:100%;}</style>
<![endif]-->' # this line is important!
    lines.join("\n")
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
  
  ############################################
  # JAVASCRIPT

  def optional_javascript_tag
    scripts = controller.class.javascript || {}
    js_files = [scripts[:all], scripts[params[:action].to_sym]].flatten.compact
    return unless js_files.any?
    extra = js_files.delete(:extra)
    js_files = js_files.collect{|i| "as_needed/#{i}" }
    if extra
      js_files += ['effects', 'dragdrop', 'controls', 'builder', 'slider']
    end
    javascript_include_tag(*js_files)
  end
  
  def crabgrass_javascripts
    lines = []
    lines << javascript_include_tag('prototype', 'application', :cache => true)
    lines << optional_javascript_tag
    lines << '<script type="text/javascript">'
    lines << @content_for_script
    lines << '</script>'
    lines << '<!--[if lt IE 7.]>'
      # make 24-bit pngs work in ie6
      lines << '<script defer type="text/javascript" src="/javascripts/ie/pngfix.js"></script>'
      # prevent flicker on background images in ie6
      lines << '<script>try {document.execCommand("BackgroundImageCache", false, true);} catch(err) {}</script>'
    lines << '<![endif]-->'
    lines.join("\n")
  end
  
  ############################################
  # BANNER

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

  ############################################
  # CONTEXT STYLES
  
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

  ###########################################
  # LAYOUT STRUCTURE

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


  ############################################
  # CUSTOMIZED STUFF

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
