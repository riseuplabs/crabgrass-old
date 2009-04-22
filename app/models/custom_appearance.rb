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
  include CustomAppearanceExtension::CssPaths
  include CustomAppearanceExtension::CssGeneration


  serialize :parameters, Hash
  serialize_default :parameters, {}

  belongs_to :admin_group, :class_name => 'Group'


  def themed_stylesheet_url(css_url)
    # append .css if missing
    css_url = ensure_dot_css(css_url)
    # path in the file system relative to RAILS_ROOT
    themed_css_path = themed_css_path(css_url)
    if !File.exists?(themed_css_path) or Conf.always_renegerate_themed_stylesheet
      # we don't have the file. generate it
      generate_css_file_for_url(themed_css_path, css_url)
    end

    # get the url for themed css
    themed_css_url(css_url)
  end

  protected

########### CLASS METHODS #####################

  class << self
    def default
      first || CustomAppearance.new
    end

    def available_parameters
      parameters = {}
      # parse the constants.sass file and return the hash
      constants_lines = File.readlines(File.join(SASS_ROOT, CONSTANTS_FILENAME))
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
