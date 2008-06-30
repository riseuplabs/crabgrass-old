module LayoutHelper

  ##########################################
  # BREADCRUMBS and CONTEXT
  
  def bread
    @breadcrumbs
  end
  
  def link_to_breadcrumbs
    if @breadcrumbs and @breadcrumbs.length > 1
      @breadcrumbs.collect{|b| link_to b[0],b[1]}.join ' &raquo; ' 
    end
  end
  
  def first_breadcrumb
    @breadcrumbs.first.first if @breadcrumbs.any?
  end
 
  def first_context
    @context.first.first if @context.any?
  end

  #########################################
  # TITLE
  
  def title_from_context
    (
      [@html_title] +
      (@context||[]).collect{|b|truncate(b[0])}.reverse +
      [Crabgrass::Config.site_name]
    ).compact.join(' - ')
  end
    
  #########################################
  # SIDEBAR 
  
  def leftbar 
    @leftbar ? "<div id='leftbar'>\n#{render :partial => @leftbar}</div>\n" : ''
  end
  
  def rightbar
    @rightbar ? "<div id='rightbar'>\n#{render :partial => @rightbar}</div>\n" : ''
  end

  def sidebar
    leftbar + rightbar
  end
  
  def sidebar_space
    style = ''
    style += "margin-left: 0;" unless @leftbar
    style += "margin-right: 0;" unless @rightbar
    style
  end
    
  ###########################################
  # STYLESHEET
  
  # custom stylesheet
  # rather than include every stylesheet in every request, some stylesheets are 
  # only included if they are needed. a controller can set a custom stylesheet
  # using 'stylesheet' in the class definition, or an action can set @stylesheet.
  # you can't do both at the same time.
  def optional_stylesheet_tag
    stylesheet_link_tag(*(optional_stylesheets.to_a))
  end
  def optional_stylesheets
    if @stylesheet
      @stylesheet # set for this action
    else
      controller.class.stylesheet # set for this controller
    end
  end
  
  def http_plain
    'http://' + controller.request.host_with_port
  end
  
  # crabgrass_stylesheets()
  # this is the main helper that is in charge of returning all the needed style
  # elements for HTML>HEAD. There are five (5!) types of stylings:
  #
  # (1) default crabgrass stylesheets (for core things like layout)
  # (2) optional stylesheets (these are stylesheets that are loaded on a
  #     per-controller or per-action basis.
  # (3) custom stylesheets (this is an empty stub, to be filled out by mods
  #     that want to easily insert their own stylesheet)
  # (4) content_for :style (inline styles set in the views)
  # (5) theme_styles (dynamic styles set based on database information, like the site or
  #     the user's customizations).
  #
  def crabgrass_stylesheets
    lines = [];
    lines << stylesheet_link_tag('application', 'page', 'navigation', 'ui', 'errors', 'landing', 'sidebar', 'wiki', :cache => true)
    lines << optional_stylesheet_tag
    lines << custom_stylesheet
    lines << '<style type="text/css">'
    lines << @content_for_style
    lines << theme_styles
    lines << '</style>'
    lines << '<!--[if IE 6]><link rel="stylesheet" href="/stylesheets/ie6.css" /><![endif]-->'
    lines << '<!--[if IE 7]><link rel="stylesheet" href="/stylesheets/ie7.css" /><![endif]-->'
    lines.join("\n")
  end

  # a hook to be overridden by mods
  def custom_stylesheet
    stylesheet_link_tag('theme')
  end

  ############################################
  # JAVASCRIPT
  
  def optional_javascript
    javascript_include_tag('effects', 'dragdrop', 'controls') if need_extra_javascript?
  end
    
  def need_extra_javascript?
    if @javascript
      @javascript == :extra
    else
      controller.class.javascript == :extra
    end
  end

  def crabgrass_javascripts
    lines = []
    lines << javascript_include_tag('prototype', 'application', :cache => true)
    lines << optional_javascript
#    lines << '<!--[if lt IE 7.]>
#  <script defer type="text/javascript" src="/javascripts/pngfix.js"></script>
#<![endif] -->'
    lines.join("\n")
  end

#  def get_unobtrusive_javascript
#    controller.get_unobtrusive_javascript
# end
  
  ############################################
  # BANNER

  # banner stuff
  def banner_style
    "background: #{@banner_style.background_color}; color: #{@banner_style.color};"
  end  
  def banner_background
    @banner_style.background_color
  end
  def banner_foreground
    @banner_style.color
  end
  def banner
    @banner_partial
  end
  
  ############################################
  # CUSTOM THEME
  
  def background_color
    "#ccc"
  end
  def background
    #'url(/images/test/grey-to-light-grey.jpg) repeat-x;'
    'url(/images/background/grey.png) repeat-x;'
  end

  # return all the custom css which might apply just to this one group
  def theme_styles
    style = []
     if banner
       style << 'body {background-color: %s}' % background_color
       style << '#main {background: %s}' % background if background
#       style << 'div.sidehead {background: %s;}' % banner_background
       style << 'div.sidehead {background: %s;}' % '#bbb'
       style << '#banner {%s}' % banner_style
       style << '#banner a.name_link {color: %s; text-decoration: none;}' %
                banner_foreground
       style << '#topmenu li.selected span a {background: %s; color: %s}' %
                [banner_background, banner_foreground]
      
       #xmain {background: #fff url(/images/shadows/small-top.png) repeat-x top;}
     end
    style.join("\n")
  end

end
