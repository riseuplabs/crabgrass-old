=begin
Defines customizable themes that override the default crabgrass appearances

This is donye by storing variables in the +parameters+ hash.
These variables are used to override SASS constants defined in public/stylesheets/sass/constants.sass

create_table "custom_appearances", :force => true do |t|
  t.text     "parameters"
  t.integer  "parent_id",  :limit => 11
  t.datetime "created_at"
  t.datetime "updated_at"
  t.integer  "admin_group_id", :limit => 11
end

=end
class CustomAppearance < ActiveRecord::Base
  CACHED_CSS_DIR = 'themes'
  CSS_ROOT_PATH = './public/stylesheets'

  # by default we won't regenerate css when sass changes
  # we only regenerate css when +self+ object is updated
  # if this is set to _true_ we will compare css and sass timestamps
  # every time and regenerate when css is older
  cattr_accessor :ignore_file_timestamps

  serialize :parameters, Hash
  serialize_default :parameters, {}

  belongs_to :admin_group, :class_name => 'Group'

  def sass_override_text
    text = ""
    parameters.each {|k, v| text << %Q[!#{k} = "#{v}"\n]}
    text << "\n"
  end

  def write_css_cache(css_path, css_text)
    # don't overwrite
    return if has_cached_css?(css_path)

    write_path = cached_css_full_path(css_path)
    write_dir = File.dirname(write_path)
    FileUtils.mkpath(write_dir)
    File.open(write_path, "w+") {|f| f.write css_text}
  end

  # returns true if this custom appearances has +css_path+ file cached.
  def has_cached_css?(css_path)
    cached = File.exists?(cached_css_full_path(css_path))

    unless CustomAppearance.ignore_file_timestamps
      cached &&= css_fresher_than_sass?(css_path)
    end

    cached
  end

  # check that source sass file is less recent
  # then the css that was generated from it
  def css_fresher_than_sass?(css_path)
    full_css_path = cached_css_full_path(css_path)
    full_sass_path = CustomAppearance.source_sass_full_path(css_path)

    # this logic doesn't work 100% right now because screen.sass depends on many *.sass files, but
    # their timestamps can't be checked. works for as_needed css
    if css_path =~ /as_needed/
      File.mtime(full_css_path) >= File.mtime(full_sass_path)
    else
      false
    end
  end

  # returns the location where css specific for this CustomAppearance should be stored
  # this path is relative to RAILS_ROOT
  # :cal-seq:
  #   appearance.cached_css_path('as_needed/wiki') => './public/stylesheets/themes/2/1237185316/as_needed/wiki.css'
  def cached_css_full_path(css_path)
    # append .css if missing
    css_path = css_path + ".css" unless css_path =~ /\.css$/
    File.join(CSS_ROOT_PATH, cached_css_root, css_path)
  end

  # returns the location where css specific for this CustomAppearance should be stored
  # this path is relative to css root (like 'public/stylesheets')
  # :cal-seq:
  #   appearance.cached_css_path('as_needed/wiki.css') => 'themes/2/1237185316/as_needed/wiki.css'
  def cached_css_stysheet_link_path(css_path)
    # append .css if missing
    css_path = css_path + ".css" unless css_path =~ /\.css$/
    File.join(cached_css_root, css_path)
  end

  # returns the root location for cached css file specific to this CustomAppearance
  # the updated_at timestamp is used to generate th path
  # :cal-seq:
  #   appearance.cached_css_root => 'themes/2/1237185316'
  def cached_css_root
    File.join(CACHED_CSS_DIR, self.id.to_s, self.updated_at.to_i.to_s)
  end

########### CLASS METHODS #####################

  class << self
    SASS_ROOT_PATH = './public/stylesheets/sass'
    CONSTANTS_FILE = "constants.sass"
    SASS_INCLUDES = [CONSTANTS_FILE]
    SASS_LOAD_PATHS = ['.', SASS_ROOT_PATH]

    def default
      first || CustomAppearance.new
    end

    def generate_css(css_path, appearance = nil)
      appearance ||= CustomAppearance.default

      full_sass_path = source_sass_full_path(css_path)#File.join(SASS_ROOT_PATH, css_path).gsub(".css", ".sass")
      sass_text = ""

      # load sass includes manually
      SASS_INCLUDES.each do |include_file|
        include_path = File.join(SASS_ROOT_PATH, include_file)
        sass_text << File.read(include_path)
      end

      # load the custom appearance variables if we have something
      sass_text << "\n" << appearance.sass_override_text if appearance

      # load the requested file
      sass_text << File.read(full_sass_path)

      # render css from or sass text
      engine = Sass::Engine.new(sass_text, :load_paths => SASS_LOAD_PATHS)
      css_text = engine.render

      appearance.write_css_cache(css_path, css_text) if appearance

      css_text
    end

    # returns the location where sass source for this +css_path+ can be found
    # this path is relative to RAILS_ROOT
    # :cal-seq:
    #   appearance.cached_css_path('as_needed/wiki') => './public/stylesheets/themes/2/1237185316/as_needed/wiki.css'
    def source_sass_full_path(css_path)
     # append .css if missing
     css_path = css_path + ".css" unless css_path =~ /\.css$/
     full_sass_path = File.join(SASS_ROOT_PATH, css_path).gsub(".css", ".sass")
    end

    def clear_cached_css
      path = File.join(CSS_ROOT_PATH, CACHED_CSS_DIR)
      pattern = path + "/**"
      FileUtils.rm_rf(Dir.glob(pattern))
    end

    def available_parameters
      parameters = {}
      # parse the constants.sass file and return the hash
      constants_lines = File.readlines(File.join(SASS_ROOT_PATH, CONSTANTS_FILE))
      constants_lines.reject! {|l| l !~ /^\s*!\w+/ }
      constants_lines.each do |l|
        k, v = l.chomp.split(/\s*=\s*/)
        k[/^!/] = ""
        parameters[k] = v
      end
      parameters
    end
  end
end
