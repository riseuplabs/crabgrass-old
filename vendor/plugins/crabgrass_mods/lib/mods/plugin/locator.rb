class Mods::Plugin::FileSystemLocator < Rails::Plugin::FileSystemLocator

  # same as super, but we return Mods::Plugin instead of Rails::Plugin
  def create_plugin(path)
    if Mods.plugin_enabled_callback.nil? or Mods.plugin_enabled_callback.call(path)
      plugin = Mods::Plugin.new(path)
      plugin.valid? ? plugin : nil
    else
      nil
    end
  end

end

