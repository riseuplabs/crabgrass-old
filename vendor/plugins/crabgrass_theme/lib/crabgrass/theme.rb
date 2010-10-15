##
## Theme - A set of configured customizations to the appearance of crabgrass
##


module Crabgrass
  class Theme
  end
end

unless defined?(info)
  def info(str,lvl=1)
    puts str
  end
end

%w[renderer cache loader options navigation_item navigation_definition].each do |file|
  require File.join(File.dirname(__FILE__), 'theme', file)
end
#require 'theme/renderer'
#require 'theme/cache'
#require 'theme/loader'
#require 'theme/options'
#require 'theme/navigation_definition'

class Crabgrass::Theme

  include Crabgrass::Theme::Renderer
  include Crabgrass::Theme::Cache
  include Crabgrass::Theme::Loader

  THEME_ROOT = RAILS_ROOT + '/app/themes'        # where theme configs live
  SASS_ROOT  = RAILS_ROOT + '/app/stylesheets'   # where the sass source files live
  CSS_ROOT   = RAILS_ROOT + '/public/theme'      # where the rendered css files live
  CORE_CSS_SHEET = 'screen'

  attr_reader :directory, :public_directory, :name, :data
  @@themes = {}

  def initialize(directory)
    @directory = File.join(THEME_ROOT,directory)
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
      @@themes[theme_name] = Loader::create_and_load(theme_name)
    else
      @@themes[theme_name] ||= Loader::create_and_load(theme_name)
    end
  end

  # access the values stored in the theme. eg current_theme[:border_width]
  def [](key)
    @data[key.to_sym]
  end

  # alternate method of accessing the configuration. eg current_theme.border_width
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
  ## THEME DEFINITION
  ##

  # used for defining the theme's options.
  # allows this in a theme's init.rb:
  # options do 
  #   ... theme options code ...
  # end

  def options(&block)
    Options.new(self).instance_eval(&block)
  end

  # used to define or fetch the navigation
  def navigation(&block)
    if block
      @navigation ||= NavigationDefinition.new
      @navigation.instance_eval(&block)
    else
      @navigation
    end
  end

  # used in init.rb to define custom theme styles

  def style(str)
    @style = str
  end

end

