namespace :test do
  namespace :mods do

    desc "Run the plugin tests in mods/**/test (or specify with MOD=name)"
    task :all => [:units, :functionals, :integration]
    
    desc "Run all plugin unit tests"
    Rake::TestTask.new(:units => :setup_plugin_fixtures) do |t|
      t.pattern = "mods/#{ENV['MOD'] || "**"}/test/unit/**/*_test.rb"
      t.verbose = true
    end
    
    desc "Run all plugin functional tests"
    Rake::TestTask.new(:functionals => :setup_plugin_fixtures) do |t|
      t.pattern = "mods/#{ENV['MOD'] || "**"}/test/functional/**/*_test.rb"
      t.verbose = true
    end
    
    desc "Integration test engines"
    Rake::TestTask.new(:integration => :setup_plugin_fixtures) do |t|
      t.pattern = "mods/#{ENV['MOD'] || "**"}/test/integration/**/*_test.rb"
      t.verbose = true
    end

    desc "Mirrors plugin fixtures into a single location to help plugin tests"
    task :setup_plugin_fixtures => :environment do
      if ENV['MOD']
        Engines::Testing.setup_plugin_fixtures([Engines.plugins.detect{|plugin|plugin.name == ENV['MOD']}])
      else
        Engines::Testing.setup_plugin_fixtures()
      end
    end
    
  end  
end

namespace :test do
  namespace :tools do

    desc "Run the plugin tests in tools/**/test (or specify with TOOL=name)"
    task :all => [:units, :functionals, :integration]
    
    desc "Run all plugin unit tests"
    Rake::TestTask.new(:units => :setup_plugin_fixtures) do |t|
      t.pattern = "tools/#{ENV['TOOL'] || "**"}/test/unit/**/*_test.rb"
      t.verbose = true
    end
    
    desc "Run all plugin functional tests"
    Rake::TestTask.new(:functionals => :setup_plugin_fixtures) do |t|
      t.pattern = "tools/#{ENV['TOOL'] || "**"}/test/functional/**/*_test.rb"
      t.verbose = true
    end
    
    desc "Integration test engines"
    Rake::TestTask.new(:integration => :setup_plugin_fixtures) do |t|
      t.pattern = "tools/#{ENV['TOOL'] || "**"}/test/integration/**/*_test.rb"
      t.verbose = true
    end

    desc "Mirrors plugin fixtures into a single location to help plugin tests"
    task :setup_plugin_fixtures => :environment do
      Engines::Testing.setup_plugin_fixtures
    end
    
  end  
end

