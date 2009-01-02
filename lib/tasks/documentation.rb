namespace :cg do
  desc "Generate documentation for Crabgrass"
  Rake::RDocTask.new("doc") { |rdoc|
    rdoc.rdoc_dir = 'doc/app'
    rdoc.template = ENV['template'] if ENV['template']
    rdoc.title    = ENV['title'] || "Crabgrass Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.options << '--charset' << 'utf-8'
    rdoc.rdoc_files.include('[A-Z]*[^~]')  # uppercase files only
    rdoc.rdoc_files.include('doc/[A-Z]*[^~]')  # uppercase files only
    rdoc.rdoc_files.include('app/**/*.rb')
    #rdoc.rdoc_files.include('app/**/**/*.rb')
    #rdoc.rdoc_files.include('lib/**/*.rb')
  }
end
