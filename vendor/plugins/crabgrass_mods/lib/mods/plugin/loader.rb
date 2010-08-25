class Mods::Plugin::Loader < Rails::Plugin::Loader

  protected

  def register_plugin_as_loaded(plugin)
    super plugin
    info('loaded plugin %s' % plugin.directory.sub(RAILS_ROOT+'/',''), 1)
  end

end
