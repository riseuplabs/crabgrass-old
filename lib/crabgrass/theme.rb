module Crabgrass

##
## ThemeOptions - a simple class used to create a theme definitions
##

class ThemeOptions

  def initialize(theme)
    @theme = theme
    @namespace = []
  end

  # method calls with blocks push a new namespace
  # everything else just captures the first argument as the value.
  def method_missing(name, *args, &block)
    name = name.to_s
    if block
      @namespace.push(name)
      instance_eval(&block)
      @namespace.pop
    else
      key = (@namespace + [name]).join('_').to_sym
      value = args.first
      @theme.data[key] = value
    end
    nil
  end

  def html(*args, &block)
    key = (@namespace + ['html']).join('_').to_sym
    value = args.first || block
    @theme.data[key] = value
    nil
  end
  
  def var(variable_name)
    @theme.data[variable_name]
  end

end

##
## Theme Helper -- a mixin for ActionView::Base
##

module ThemeHelper
  def theme_render(key)
    value = current_theme[key.to_sym]
    return unless value
    if value.is_a? Proc
      self.instance_eval &value
    elsif value.is_a? Hash
      render value
    elsif value.is_a? String
      value
    end
  end
end

##
## Theme - A set of configured customizations to the appearance of crabgrass
##

class Theme

  THEME_ROOT = RAILS_ROOT + '/app/themes'        # where theme configs live
  SASS_ROOT  = RAILS_ROOT + '/app/stylesheets'   # where the sass source files live
  CSS_ROOT   = RAILS_ROOT + '/public/theme'      # where the rendered css files live
  CORE_CSS_SHEET = 'screen'

  attr_reader :directory, :name, :data

  def initialize(directory)
    @directory = directory
    @name      = File.basename(@directory) rescue nil
    @public_directory = File.join(CSS_ROOT,@name)
    @data      = {}
    @style     = nil
  end

  # grabs a theme by name, loading if necessary. In production mode, theme is
  # kept loaded in the memory until the app is restarted. In development mode,
  # the theme is loaded each time (but we call this only once per request).
  # usage: 
  #   Theme['default'] => <theme>
  def self.[](theme_name)
    if RAILS_ENV=='development'
      Conf.themes[theme_name] = create_and_load(theme_name)
    else
      Conf.themes[theme_name] ||= create_and_load(theme_name)
    end
  end

  def [](key)
    @data[key.to_sym]
  end

  def method_missing(key)
    @data[key.to_sym]
  end

  ##
  ## THEME URLS
  ##

  # returns an absolute url path, specific to this theme, given a sheet name
  # e.g. 
  #   stylesheet_url('screen') => /theme/default/screen.css

  def stylesheet_url(sheet_name)
    clear_cache_if_needed(sheet_name)
    File.join('','theme', @name, sheet_name + '.css')
  end

  # given a resource or file, returns an absolute url path that
  # points to the correct url in the theme's public image directory
  # a named resouce:
  #   url('favicon') => /theme/default/images/my_favicon.png
  # a file:
  #   url('background.jpg') => /theme/default/images/background.jpg
  # in general, named resources should be used instead of file names
  # in order to allow themes to selectively override images.
  def url(image_name)
    filename = @data[image_name.to_sym] || image_name
    File.join('','theme', @name, 'images', filename)
  end

  ##
  ## THEME CONFIGURATION
  ##

  public

  # used for defining the theme's options.
  # allows this in a theme's init.rb:
  # options do 
  #   ... theme options code ...
  # end

  def options(&block)
    ThemeOptions.new(self).instance_eval(&block)
  end

  # used in init.rb to define custom theme styles

  def style(str)
    @style = str
  end

  ##
  ## THEME CSS RENDERING
  ##

  public

  # returns rendered css from a sass source file

  def render_css(file)
    sass_text = generate_sass_text(file)
    Sass::Engine.new(sass_text, sass_options).render
  end

  # print out a nice error message if anything goes wrong
  def error_response(exception)
    txt = []
    txt << "<html><body>"
    txt << "<h2>#{exception}</h2>"
    txt << "<blockquote>Line number: #{exception.sass_line}<br/>"
    txt << "File: #{exception.sass_filename}</blockquote>"
    if !exception.sass_filename.nil? and exception.sass_filename !~ /screen/
      print_sass_source(txt, File.read(exception.sass_filename).split("\n"))
    end
    print_sass_source(txt, exception.sass_template.split("\n"))
    txt << "</body></html>"
    txt.join("\n")
  end

  private

  def print_sass_source(txt, data)
    line_number = 1
    txt << "<pre>"
    data.each do |line|
      txt << "%4.i  %s" % [line_number, line]
      line_number += 1
    end
    txt << "</pre>"
  end

  # takes a sass file, and prepends the variable declarations for this theme.
  # returns a text blob that is the completed sass.

  def generate_sass_text(file)
    # reload_theme_if_needed
    sass = []
    sass << '// VARIABLES FROM %s' % @directory
    data.collect do |key,value|
      if skip_variable?(key)
        next
      elsif mixin_variable?(key)
        sass << "@mixin #{key} {"
        sass << value
        sass << "}"
        sass << '$%s: true;' % key
      else
        if quote_sass_variable?(value)
          sass << '$%s: "%s";' % [key,value]
        else
          sass << '$%s: %s;' % [key,value]
        end
      end
    end
    sass << ""
    sass << '// FILE FROM %s' % sass_source_path(file)
    sass << File.read( sass_source_path(file) )
    if @style and file == Theme::CORE_CSS_SHEET
      sass << '// CUSTOM CSS FROM THEME'
      sass << @style
    end
    return sass.join("\n")
  end

  # when definiting sass variables, it matters a lot whether the value
  # is quoted or not, because this is passed on to css.
  # see http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#variables_
  #
  # this method determines if we should puts quotes or not.

  def quote_sass_variable?(value)
    if value =~ /^#/
      false
    elsif value =~ /(px|em|%)$/
      false
    elsif value =~ /^\dpx (solid|dotted)/
      # looks like a border definition
      false
    elsif value =~ /aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow|light|dark/
      value =~ / /
    elsif value.is_a? String
      true
    else
      false
    end
  end

  def mixin_variable?(key)
    key.to_s =~ /_css$/
  end

  def skip_variable?(key)
    key.to_s =~ /_html$/
  end

  # given a css sheet name, return the corresponding sass file
  # e.g.
  #   'screen' => '/usr/apps/crabgrass/app/stylesheets/screen.sass'

  def sass_source_path(sheet_name)
    File.join(Theme::SASS_ROOT, sheet_name + '.scss')
  end

  # given a css sheet name, return the corresponding themed css file
  # e.g.
  #   'screen' => '/usr/apps/crabgrass/public/theme/default/screen.css'

  def css_destination_path(sheet_name)
    File.join(@public_directory, sheet_name.empty? ? "" : sheet_name + '.css')
  end

  def sass_options
    options = Compass.configuration.to_sass_engine_options
    options.merge(
      :debug_info => false,
      :style => :nested,
      :line_comments => false,
      :syntax => :scss
#     :cache => false
    )
  end

  ##
  ## CSS CACHE
  ##

  public

  def clear_cache(file='')
    cached = css_destination_path(file)
    FileUtils.rm_r(cached, :secure => true) if File.exists? cached
  end

  private
  
  def clear_cache_if_needed(sheet_name)
    if RAILS_ENV == 'development'
      updated_at = css_updated_at(sheet_name)
      if updated_at
        if File.mtime(init_path) > updated_at
          load
          clear_cache
        elsif sass_updated_at(sheet_name) > updated_at
          clear_cache(sheet_name)
        end
      end
    end
  end

  # used to determine if the theme's css files need to be regenerated.

  def sass_updated_at(sheet_name)
    if sheet_name == 'screen'
      newest = File.mtime(sass_source_path('screen'))
      sass_files_for_screen.each do |sass_file|
         newest = [File.mtime(sass_file), newest].max
      end
      return newest
    else
      return File.mtime(sass_source_path(sheet_name))
    end
  end

  def css_updated_at(sheet_name)
    path = css_destination_path(sheet_name)
    File.exists?(path) ? File.mtime(path) : nil
  end

  def sass_files_for_screen
    # grab everything. not sure what might be in screen.
    Dir.glob( ['/*.sass', '/*.scss', '/*/*.sass', '/*/*.scss'].collect{|d|Theme::SASS_ROOT+d} )
  end

  ##
  ## THEME LOADING AND STORAGE
  ##

  public

  def load
    info 'loading theme %s' % @directory, 1

    # load and eval theme init.rb
    evaluate_init_rb

    # in production, clear the cache once at startup.
    clear_cache if RAILS_ENV == 'production'

    # create the theme's public directory and link the theme's
    # 'images' directory to it.
    unless File.exists?(@public_directory)
      FileUtils.mkdir_p(@public_directory)
    end
    if File.exists?("#{@public_directory}/images")
      FileUtils.rm("#{@public_directory}/images") # it might be pointing to wrong path
    end
    FileUtils.ln_s("#{@directory}/images", "#{@public_directory}/images")
  end

  private

  def self.create_and_load(theme_name)
    theme = Theme.new( File.join(Theme::THEME_ROOT, theme_name) )
    theme.load
    theme
  end

  def evaluate_init_rb
    eval(IO.read(init_path), binding, init_path)
  end

  def init_path
    @directory + '/init.rb' 
  end

end

end # end module Crabgrass

ActionView::Base.send(:include, Crabgrass::ThemeHelper)

