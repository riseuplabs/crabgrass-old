namespace :cg do 

  desc "Load seed database data (from config/db) into the current environment's database." 
  task :load_default_data => :environment do
    require 'active_record/fixtures'
    Dir.glob(RAILS_ROOT + '/config/db/*.yml').each do |file|
      Fixtures.create_fixtures('config/db', File.basename(file, '.*'))
    end
  end

end

