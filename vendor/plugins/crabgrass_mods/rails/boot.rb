require File.join(File.dirname(__FILE__), '/../lib/mods')

# initialize Rails::Configuration with our own default values to spare users
# some hassle with the installation and keep the environment cleaner

{
  # use a custom locator
  :default_plugin_locators => [Mods::Plugin::FileSystemLocator],

  # use a custom loader
  :default_plugin_loader => Mods::Plugin::Loader,

  # load the mods plugin before the others!
  :default_plugins => [:crabgrass_mods, :all]

}.each do |name, default|
  Rails::Configuration.send(:define_method, name) { default }
end

