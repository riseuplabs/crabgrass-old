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
  serialize :parameters, Hash


  def sass_override_text
    text = ""
    parameters.each {|k, v| text << %Q[!#{k} = "#{v}"\n]}
    text << "\n"
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
      full_sass_path = File.join(SASS_ROOT_PATH, css_path).gsub(".css", ".sass")
      sass_text = ""

      # load sass includes manually
      SASS_INCLUDES.each do |include_file|
        include_path = File.join(SASS_ROOT_PATH, include_file)
        sass_text << File.read(include_path)
      end

      # load the requested file
      sass_text << File.read(full_sass_path)

      # load the custom appearance variables if we have something
      sass_text << "\n" << appearance.sass_override_text if appearance

      # render css from or sass text
      engine = Sass::Engine.new(sass_text, :load_paths => SASS_LOAD_PATHS)
      engine.render
    end
  end
end
