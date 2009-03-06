namespace :sites do
  task :load_from_yml => :environment do
    # bail if not empty
    unless Site.find(:all).empty? or ENV["FORCE_OVERWRITE"] == "true"
      raise "Refusing to destroy existing sites data. Run with 'FORCE_OVERWRITE=true'"
    end
    # destroy everything
    Site.find(:all).each {|s| s.destroy}

    if RAILS_ENV=="production"
      config_file = 'sites.yml'
    else
      config_file = 'development.sites.yml'
    end

    config_path = File.join(RAILS_ROOT, "config", config_file)

    site_configs = YAML.load_file(config_path)

    site_configs.each do |label, config|
      config.delete("secret")
      if config["default_language"].is_a? Array
        config["default_language"] = config["default_language"].first
      end

      site = Site.new(config)
      site.save!
    end
  end
end