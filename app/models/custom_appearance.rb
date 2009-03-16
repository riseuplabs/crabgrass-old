=begin
Defines customizable themes that override the default crabgrass appearances

This is donye by storing variables in the +parameters+ hash.
These variables are used to override SASS constants defined in public/stylesheets/sass/constants.sass

create_table "custom_appearances", :force => true do |t|
  t.text     "parameters"
  t.integer  "parent_id",  :limit => 11
  t.datetime "created_at"
  t.datetime "updated_at"
end

=end
class CustomAppearance < ActiveRecord::Base
  CUSTOM_CSS_PATH = 'themes'
  CSS_ROOT_PATH = './public/stylesheets'

  serialize :parameters, Hash

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
    File.exists?(cached_css_full_path(css_path))
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
    File.join(CUSTOM_CSS_PATH, self.id.to_s, self.updated_at.to_i.to_s)
  end

######### DEFAULT SERIALIZED VALUES ###########
  # :cal-seq:
  #   appearance.parameters => {"page_bg_color" => "#fff"}
  def parameters
    read_attribute(:parameters) || write_attribute(:parameters, {})
  end

########### CLASS METHODS #####################

  class << self
    SASS_ROOT_PATH = './public/stylesheets/sass'
    SASS_INCLUDES = ["constants.sass"]
    SASS_LOAD_PATHS = ['.', SASS_ROOT_PATH]

    def default
      first
    end

    def generate_css(css_path, appearance = nil)
      appearance ||= CustomAppearance.default

      full_sass_path = File.join(SASS_ROOT_PATH, css_path).gsub(".css", ".sass")
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
  end
end
