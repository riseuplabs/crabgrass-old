# This taks get translations from the database and write to YAML files

namespace :cg do
  namespace :l10n do
    desc "Get translations from the database and write to YAML files"
    task(:db2yaml) do
      FileUtils.mkdir_p File.join(RAILS_ROOT, 'lang') # Ensure we have lang dir
      `ruby lib/tasks/db2yaml.rb`
      puts "\nYAML files written to 'lang' directory\n"
    end
  end
end
