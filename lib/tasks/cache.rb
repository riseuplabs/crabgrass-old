namespace :clear do
  task :css_cache do
    FileUtils.rm_rf(Dir.glob("./public/stylesheets/themes/**"))
  end
end