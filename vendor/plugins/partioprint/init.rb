if RAILS_ENV == "development"
  Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each do |file|
    require file
  end
end