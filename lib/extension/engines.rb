=begin

In crabgrass, we want plugins to be able to override the views in the
main application. This is not possible in normal engines plugins.

Also, it is nice, and timetimes necessary, to be able to turn off the
default behavior of how rails loads plugins. Normally, plugins are loaded
once. It is nice to change this if you are developing a plugin (so that you
don't have to restart the server on each change) and it is necessary to
change this if any main application classes are first loaded from your plugin
(because in these cases, by default they will stick around but then get loaded
somewhere else and rails will freak out).

Here we provide two options that can be set in a plugin's init.rb:

  self.override_views = true
  self.load_once = false

Here is another way of achieving the load_once=false effect:
http://cameronyule.com/2008/07/make-rails-engines-2-reload-in-development-mode

=end

require 'dispatcher'

Engines::Plugin.class_eval do
  # Plugins may set this to true if they want their views to
  # take precedence over the views in the main application.
  # Otherwise, views in plugins that duplicate views in the
  # application are ignored.
  # 
  # Defaults to false.
  attr_accessor :override_views

  # Plugins may set this to false in order to prevent their code from caching
  # in development mode (in other words, false will force the code to loaded
  # on each request).
  #
  # Defaults to true. 
  attr_reader :load_once
  def load_once=(new_value)
    @load_once = new_value
    if @load_once
      load_paths.each { |p| Dependencies.load_once_paths << p }
    else
      load_paths.each { |p| Dependencies.load_once_paths.delete(p) }
    end
  end
  
  def initialize(directory)
    super directory
    @code_paths = default_code_paths
    @controller_paths = default_controller_paths
    @public_directory = default_public_directory
    @override_views = false
    @load_once = true
  end
  
  def add_plugin_view_paths
    view_path = File.join(directory, 'app', 'views')
    if File.exist?(view_path)
      if @override_views
        ActionController::Base.prepend_view_path(view_path)
      else
        ActionController::Base.view_paths.insert(1, view_path) # push it just underneath the app
      end
      ActionView::TemplateFinder.process_view_paths(view_path)
    end
  end

  #
  # Some plugins have a problem: if a plugin applies a mixing directly to a 
  # model in app/models, this mixin gets unloaded by rails after the first request.
  # This only happens in development mode. The symptom is an application that works
  # for the first request but fails on subsiquent requests. 
  #
  # This is an attempt to get around that problem by re-applying any mixin
  # that modifies the core models on each request. 
  # 
  # Normal plugins don't have this problem: they modify active record, and then
  # the core models call these extensions which triggers the reloading of the 
  # plugin mixin.
  #
  def apply_mixin_to_model(model_class, mixin_module)
    Dispatcher.to_prepare {
      model_class  = Kernel.const_get(model_class.to_s)  # \ weird, yet
      mixin_module = Kernel.const_get(mixin_module.to_s) # / required.
      if modname = mixin_module.const_get("ClassMethods")
        model_class.send(:extend, modname)
      end rescue NameError
      if modname = mixin_module.const_get("InstanceMethods")
        model_class.send(:include, modname)
      end rescue NameError
      if mixin_module.respond_to? :add_to_class_definition
        model_class.instance_eval &(mixin_module.add_to_class_definition())
      end
    }
  end 

end

Engines::Plugin::FileSystemLocator.class_eval do
  # This starts at the base path looking for valid plugins (see Rails::Plugin#valid?).
  # Since plugins can be nested arbitrarily deep within an unspecified number of
  # intermediary directories, this method runs recursively until it finds a plugin
  # directory, e.g.
  #
  #     locate_plugins_under('vendor/plugins/acts/acts_as_chunky_bacon')
  #     => <Rails::Plugin name: 'acts_as_chunky_bacon' ... >
  #
  # crabgrass hack: only load the plugins in mods/ and pages/ if they are in
  # or MODS_ENABLED or PAGES_ENABLED
  #
  def locate_plugins_under(base_path)
    Dir.glob(File.join(base_path, '*')).inject([]) do |plugins, path|
      ## begin crabgrass hack
      next(plugins) if path =~ /#{RAILS_ROOT}\/mods\//  and !MODS_ENABLED.include?(File.basename(path))
      next(plugins) if path =~ /#{RAILS_ROOT}\/tools\// and !TOOLS_ENABLED.include?(File.basename(path))
      ## end crabgrass hack
      if plugin = create_plugin(path)
        plugins << plugin
      elsif File.directory?(path)
        plugins.concat locate_plugins_under(path)
      end
      plugins
    end
  end
end

# The engines plugin dumps way too much stuff to the development log.
# By default, we want to raise the level to INFO instead of DEBUG,
# but only for the engines logger, not the default rails one.
# (this is done in development.rb)
module Engines
  def self.logger
    @@logger ||= RAILS_DEFAULT_LOGGER
  end
  def self.logger=(lgr)
    @@logger = lgr
  end
end

