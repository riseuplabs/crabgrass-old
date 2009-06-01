# Generates a migration which migrates all plugins to their latest versions
# within the database.
class PluginMigrationGenerator < Rails::Generator::Base
  
  def initialize(runtime_args, runtime_options={})
    super
    @options = {:assigns => {}}
    
    ensure_plugin_schema_table_exists
    get_plugins_to_migrate(runtime_args)
    
    if @plugins_to_migrate.empty?
      puts "All plugins are migrated to their latest versions"
      exit(0)
    end

    @options[:migration_file_name] = build_migration_name
    @options[:assigns][:class_name] = build_migration_name.classify
  end
  
  def manifest
    record do |m|
      m.migration_template 'plugin_migration.erb', 'db/migrate', @options
    end
  end
  
  protected
  
    # Create the plugin schema table if it doesn't already exist. See
    # Engines::RailsExtensions::Migrations#initialize_schema_migrations_table_with_engine_additions
    def ensure_plugin_schema_table_exists
      ActiveRecord::Base.connection.initialize_schema_migrations_table
    end

    # Determine all the plugins which have migrations that aren't present
    # according to the plugin schema information from the database.
    def get_plugins_to_migrate(plugin_names)

      # First, grab all the plugins which exist and have migrations
      @plugins_to_migrate = if plugin_names.empty?
        Engines.plugins
      else
        plugin_names.map do |name| 
          Engines.plugins[name] ? Engines.plugins[name] : raise("Cannot find the plugin '#{name}'")
        end
      end
      # require 'ruby-debug';debugger
      
      @plugins_to_migrate.reject! { |p| p.latest_migration.nil? }
      
      # Then find the current versions from the database    
      @current_versions = {}
      @plugins_to_migrate.each do |plugin|
        @current_versions[plugin.name] = Engines::Plugin::Migrator.current_version(plugin)
      end

      # Then find the latest versions from their migration directories
      @new_versions = {}      
      @plugins_to_migrate.each do |plugin|
        @new_versions[plugin.name] = plugin.latest_migration
      end

      # Remove any plugins that don't need migration
      @plugins_to_migrate.map { |p| p.name }.each do |name|
        @plugins_to_migrate.delete(Engines.plugins[name]) if @current_versions[name] == @new_versions[name]
      end

      # begin crabgrass hack
      # reject plugins which already have migration files
      @plugins_to_migrate.reject! do |plugin|
        migration_file_name = "#{plugin.name}_to_version_#{@new_versions[plugin.name]}"
        migration_file_exists?(migration_file_name)
      end
      # end crabgrass hack

      @options[:assigns][:plugins] = @plugins_to_migrate
      @options[:assigns][:new_versions] = @new_versions
      @options[:assigns][:current_versions] = @current_versions
    end

    # Construct a unique migration name based on the plugins involved and the
    # versions they should reach after this migration is run.
    def build_migration_name
      @plugins_to_migrate.map do |plugin| 
        "#{plugin.name}_to_version_#{@new_versions[plugin.name]}" 
      end.join("_and_")
    end
    
    # a crabgrass hack
    # checks to see if a file exists for this migration
    def migration_file_exists?(migration_name)
      !Dir.glob("#{RAILS_ROOT}/db/migrate/[0-9]*_*.rb").grep(/#{migration_name}/).empty?
    end
end