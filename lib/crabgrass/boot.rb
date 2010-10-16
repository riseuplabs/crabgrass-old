# load the mods plugin first, it modifies how the plugin loading works
require "#{RAILS_ROOT}/vendor/plugins/crabgrass_mods/rails/boot"

# do this early because environments/*.rb need it
require File.dirname(__FILE__) + '/conf'

# load hook support early
require File.dirname(__FILE__) + '/hook'

# load Crabgrass::Initializer early
require File.dirname(__FILE__) + '/initializer'

# load configuration file
Conf.load("crabgrass.#{RAILS_ENV}.yml")

# control which plugins get loaded and are reloadable
Mods.plugin_enabled_callback = Conf.method(:plugin_enabled?)
Mods.plugin_reloadable_callback = Conf.method(:plugin_reloadable?)

begin
  secret_path = File.join(RAILS_ROOT, "config/secret.txt")
  Conf.secret = File.read(secret_path).chomp
rescue
  unless ARGV.first == "create_a_secret"
    raise "Can't load the secret key from file #{secret_path}. Have you run 'rake create_a_secret'?"
  end
end

# TODO: banish SECTION_SIZE and replace with current_site.pagination_size
SECTION_SIZE = Conf.pagination_size

# path in which zipped galleries (for download) will be stored.
# TODO: can this be moved somewhere better? it should be in a plugin.
require "#{RAILS_ROOT}/lib/zip/zip.rb"
GALLERY_ZIP_PATH = "#{RAILS_ROOT}/public/gallery_download"
unless File.exists?(GALLERY_ZIP_PATH)
  Dir.mkdir(GALLERY_ZIP_PATH)
end

## not sure what this was for:
# possible in plugin?
#class Rails::Configuration
#  attr_accessor :action_web_service
#end

