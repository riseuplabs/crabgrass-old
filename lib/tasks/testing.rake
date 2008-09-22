namespace :test do
  Rake::TestTask.new(:tools => :environment) do |t|
    t.libs << "test"

    if ENV['TOOL']
      t.pattern = "tools/#{ENV['PLUGIN']}/test/*_test.rb"
    else
      t.pattern = 'tools/*/test/*_test.rb'
    end

    t.verbose = true
  end
  # Rake::Task['test:tool'].comment = "Run the tool tests in tools/*/test (or specify with TOOL=name)"

  Rake::TestTask.new(:mods => :environment) do |t|
    t.libs << "test"

    if ENV['MOD']
      t.pattern = "mods/#{ENV['MOD']}/test/*_test.rb"
    else
      t.pattern = 'mods/*/test/*_test.rb'
    end

    t.verbose = true
  end
end

