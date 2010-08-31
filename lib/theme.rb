##
## ThemeOptions - a simple class used to create a theme definitions
##

class ThemeOptions
  def initialize(theme)
    @theme = theme
    @namespace = []
  end
  def method_missing(name, *args, &block)
    if block
      @namespace.push(name.to_s)
      instance_eval(&block)
      @namespace.pop
    else
      key = (@namespace + [name.to_s]).join('_').to_sym
      value = args.first
      @theme.data[key] = value
    end
    self
  end
end

##
## Theme - A set of configured customizations to the appearance of crabgrass
##

class Theme

  THEME_ROOT = RAILS_ROOT + '/app/themes'        # where theme configs live
  SASS_ROOT  = RAILS_ROOT + '/app/stylesheets'   # where the sass source files live
  CSS_ROOT   = RAILS_ROOT + '/public/theme'      # where the rendered css files live

  attr_reader :directory, :name, :data

  def initialize(directory)
    @directory = directory
    @name      = File.basename(@directory) rescue nil
    @public_directory = File.join(CSS_ROOT,@name)
    @data      = {}
  end

  # grabs a theme by name, loading if necessary.
  # In production mode, theme is kept loaded in the memory
  # until the app is restarted. In development mode, the
  # theme is reloaded if any of its files change.
  # usage: 
  #   Theme['default'] => <theme>

  def self.[](theme_name)
    Conf.themes[theme_name] ||= begin
      theme = Theme.new( File.join(Theme::THEME_ROOT, theme_name) )
      theme.load
      theme
    end
  end

  def [](key)
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
  ## THEME CSS RENDERING
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
    txt << "<pre>"
    line_number = 1
    if exception.sass_filename.nil? or exception.sass_filename =~ /screen/
      filedata = exception.sass_template.split("\n")
    else
      filedata = File.read(exception.sass_filename).split("\n")
    end
    filedata.each do |line|
      txt << "%4.i  %s" % [line_number, line]
      line_number += 1
    end
    txt << "</pre>"
    txt << "</body></html>"
    txt.join("\n")
  end

  private

  # takes a sass file, and prepends the variable declarations for this theme.
  # returns a text blob that is the completed sass.

  def generate_sass_text(file)
    sass = data.collect{|k,v| '$%s: "%s"' % [k,v] }.join("\n")
    sass << "\n"
    sass << File.read( sass_source_path("mixins") )
    sass << "\n"
    sass << File.read( sass_source_path(file) )
    return sass
  end

  # given a css sheet name, return the corresponding sass file
  # e.g.
  #   'screen' => '/usr/apps/crabgrass/app/stylesheets/screen.sass'

  def sass_source_path(sheet_name)
    File.join(Theme::SASS_ROOT, sheet_name + '.sass')
  end

  # given a css sheet name, return the corresponding themed css file
  # e.g.
  #   'screen' => '/usr/apps/crabgrass/public/theme/default/screen.css'

  def css_destination_path(sheet_name)
    File.join(@public_directory, sheet_name.empty? ? "" : sheet_name + '.css')
  end

  def sass_options
    options = Compass.configuration.to_sass_engine_options
    options.merge(:debug_info => true, :style => :nested, :line_comments => false)
  end

  ##
  ## CSS CACHE
  ##

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

  def clear_cache(file='')
    cached = css_destination_path(file)
    FileUtils.rm_r(cached, :secure => true) if File.exists? cached
  end

  # used to determine if the theme's css files need to be regenerated.

  def sass_updated_at(sheet_name)
    if sheet_name == 'screen'
      newest = File.mtime(sass_source_path('screen'))
      Dir.glob(Theme::SASS_ROOT + '/core/*.sass').each do |sass_file|
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

  def loaded?
    @loaded
  end

  def evaluate_init_rb
    eval(IO.read(init_path), binding, init_path)
  end

  def init_path
    @directory + '/init.rb' 
  end

end

