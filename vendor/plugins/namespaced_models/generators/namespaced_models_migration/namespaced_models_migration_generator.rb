class NamespacedModelsMigrationGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    usage unless @args.empty?
  end

  def banner
    "Usage: #{$0} #{spec.name}"
  end

  def manifest
    record do |m|
      m.migration_template 'namespaced_models_migration.rb', 'db/migrate'
    end
  end
  
  def file_name
    'namespaced_models_migration.rb'
  end
end
