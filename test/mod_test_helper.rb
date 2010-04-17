require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ActiveSupport::TestCase

  # Add more helper methods to be used by all mod tests here...

  def mod_disabled_or_migrations_fail?
    mod_disabled? or !mod_migrate
  end

  def mod_disabled?
    !mod_enabled?
  end

  def mod_enabled?
    Conf.enabled_mods.include? mod_name
  end

  def mod_name
    self.class.name.split('::').first.underscore
  end

  ### MOD MIGRATIONS

  def mod_migrate
    engines_plugin_migrate mod_name
  end

  # apply the latest migrations from the plugin to the DB
  def engines_plugin_migrate(plugin_name)
    plugin = Engines.plugins[plugin_name]
    current_version = Engines::Plugin::Migrator.current_version(plugin)
    latest_version = plugin.latest_migration
    migration_file_exists = !Dir.glob(RAILS_ROOT + "/db/migrate/*#{plugin.name}_to_version_#{latest_version}.rb").empty?

    return true if migration_file_exists
    if latest_version.to_i > current_version.to_i
      plugin.migrate(latest_version)
    end
    latest_version == Engines::Plugin::Migrator.current_version(plugin)
  end

end
