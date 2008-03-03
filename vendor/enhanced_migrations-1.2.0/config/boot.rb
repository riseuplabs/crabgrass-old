unless defined?(RAILS_ROOT)
  root_path = File.join(File.dirname(__FILE__), '..')

  unless RUBY_PLATFORM =~ /mswin32/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end

  RAILS_ROOT = root_path
end

unless defined?(Rails::Initializer)
  if File.directory?("#{RAILS_ROOT}/vendor/rails")
    require "#{RAILS_ROOT}/vendor/rails/railties/lib/initializer"
  else
    require 'rubygems'

    rails_gem = Gem.cache.search('rails').find_all { |g| g.name == 'rails' }.sort { |a,b| a.version <=> b.version }.last rescue nil
    raise "Couldn't find rails(#{rails_gem_version}" unless rails_gem
    require_gem rails_gem.name, rails_gem.version.version
    require rails_gem.full_gem_path + '/lib/initializer'
  end

  Rails::Initializer.run(:set_load_path)
end
