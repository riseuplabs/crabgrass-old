namespace :clear do
  task :css_cache => :environment do
    # FileUtils.rm_rf(Dir.glob("./public/stylesheets/themes/**"))
    CustomAppearance.clear_cached_css
  end
end