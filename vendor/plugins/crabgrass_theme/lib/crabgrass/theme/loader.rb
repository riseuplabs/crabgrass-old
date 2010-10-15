##
## THEME LOADING AND STORAGE
##

require 'fileutils'

module Crabgrass::Theme::Loader
 
  public

  def load
    info 'loading theme %s' % @directory, 1

    # load and eval theme
    init_paths.each do |file|
      evaluate_theme_definition(file)
    end

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
    theme = Crabgrass::Theme.new( theme_name )
    theme.load
    theme
  end

  def evaluate_theme_definition(file)
    eval(IO.read(file), binding, file)
  end

  def init_paths
    paths = []
    paths << @directory+'/init.rb' if File.exist?(@directory+'/init.rb')
    paths << @directory+'/navigation.rb' if File.exist?(@directory+'/navigation.rb')
    raise 'ERROR: no theme definition files in %s' % @directory unless paths.any?
    return paths
  end

end

