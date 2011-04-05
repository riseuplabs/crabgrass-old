namespace :cg do
  task :create_default_site_widgets => :environment do
    name = ensure_site(ENV['SITE'])
    widgets = load_widgets(ENV['WIDGETS'] || 'old')
    if name == 'ALL'
      Site.all.each do |site|
        clear_widgets(site) if ENV['CLEAR']
        add_widgets(site, widgets)
      end
    elsif site = Site.find_by_name(name)
      clear_widgets(site) if ENV['CLEAR']
      add_widgets(site, widgets)
    end
  end
end

def self.ensure_site(name)
  if name.blank?
    puts 'ERROR: site name required, use SITE=<name> to specify the name or SITE=ALL'
    exit
  end
  name
end

def self.load_widgets(filename)
  filename += '_widgets.yml' unless filename.index('yml')
  filename = [RAILS_ROOT, 'lib', 'tasks', filename].join('/')
  YAML.load_file(filename)
end

def self.clear_widgets(site)
  puts "Clearing widgets from site #{site.name}..."
  return unless profile = get_profile(site)
  profile.widgets.destroy_all
end

def self.add_widgets(site, widgets)
  return unless profile = get_profile(site)
  puts "Creating widgets for site #{site.name}..."
  widgets.each do |params|
    puts "Creating widget #{params['name']}."
    unless profile.widgets.create(params)
      puts "... failed - please make sure the widget settings are valid."
    end
  end
end

def self.get_profile(site)
  unless site.network && profile = site.network.profiles.public
    puts "ERROR: site #{site.name} does not have a network with a public profile."
    return
  end
  profile
end
