namespace :cg do
  task :create_default_site_widgets => :environment do
    name = ensure_site(ENV['SITE'])
    widgets = load_widgets(ENV['WIDGETS'] || 'old')
    if name == 'ALL'
      Site.all.each do |site|
        add_widgets(site, widgets)
      end
    elsif site = Site.find_by_name(name)
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
  filename = [RAILS_ROOT, 'test', 'fixtures', filename].join('/')
  YAML.load_file(filename)
end

def self.add_widgets(site, widgets)
  unless site.network && profile = site.network.profiles.public
    puts "ERROR: site #{site.name} does not have a network with a public profile."
    return
  end
  puts "Creating widgets for site #{site.name}..."
  widgets.values.each do |params|
    puts "Creating widget #{params['name']}."
    profile.widgets.create(params)
  end
end
