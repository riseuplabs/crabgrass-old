namespace :cg do
  task :create_default_site_widgets => :environment do
    unless name = ENV['SITE']
      puts 'ERROR: site name required, use SITE=<name> to specify the name or SITE=ALL'
      exit
    end
    if name == 'ALL'
      Site.all.each do |s|
        add_widgets(s)
      end
    elsif s = Site.find_by_name(name)
      add_widgets(s)
    end
  end
end

def self.add_widgets(s)
  unless s.network && s.network.profiles.public
    puts "ERROR: site #{s.name} does not have a network with a public profile."
    return
  end
  puts "Creating widgets for site #{s.name}..."
  profile_id = s.network.profiles.public.id
  filename = (ENV['WIDGETS'] || 'old')
  filename += '_widgets.yml' unless filename.index('yml')
  filename = [RAILS_ROOT, 'test', 'fixtures', filename].join('/')
  widgets = YAML.load_file(filename)
  widgets.values.each do |w|
    create_with_options(w.merge({:profile_id => profile_id}))
  end
end

def self.create_with_options(options)
  if ENV['DEBUG']
    puts 'Creating widget with options '+options.inspect
  else
    puts "Creating widget #{options['name']}."
  end
  Widget.create(options)
end
