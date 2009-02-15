namespace :cg do

=begin
  ##
  ## this code seems to be missing doc/*
  ## 

  output_dir = 'doc/app'
  target = output_dir + '/index.html'
  files = Rake::FileList.new
  files.include('[A-Z]*[^~]')  # uppercase files only
  files.include('doc/[A-Z]*[^~]')  # uppercase files only
  files.include('app/**/*.rb')

  options    = []
  options << '--line-numbers'
  options << '--inline-source'
  options << '--charset'      << 'utf-8'
  options << '-o'             << output_dir
  options << '--main'         << 'README'
  options << '--title'        << 'Crabgrass Documentation'
  options << '--template'     << 'html'

  args = options + files

  desc 'Generate documentation for Crabgrass'
  task 'rdoc' => [target]
  file target => files do
    require 'rdoc/rdoc'
    RDoc::RDoc.new.document(args)
  end
=end

  ##
  ## this code seems to produce duplicate html rendering steps...
  ##
  ## i think they differ. the first seems to be a call to the app:doc
  ## task in rails itself. At least removing all the redoc_files_include
  ## lines but one from the app:doc task in 
  ##  /var/lib/gems/1.8/gems/rails-2.1.0/
  ## really seems to speed things up.
  ## the second seems to be this task.
  ## no idea why. 
  ##    --azul

  desc "Generate documentation for Crabgrass"
  # (creates tasks cg:rdoc, cg:clobber_rdoc, cg:rerdoc)
  Rake::RDocTask.new { |rdoc|
    rdoc.rdoc_dir = 'doc/app'
    rdoc.template = ENV['template'] if ENV['template']
    rdoc.title    = ENV['title'] || "Crabgrass Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.options << '--charset' << 'utf-8'
    rdoc.main = 'README'
    rdoc.rdoc_files.include('[A-Z]*[^~]')  # uppercase files only
    rdoc.rdoc_files.include('doc/[A-Z]*[^~]')  # uppercase files only
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('app/**/**/*.rb')
    rdoc.rdoc_files.include('lib/path_finder/**/*.rb')
    rdoc.rdoc_files.include('lib/path_finder/[A-Z]*[^~]')
    rdoc.rdoc_files.include('lib/path_finder.rb')
  }

end
