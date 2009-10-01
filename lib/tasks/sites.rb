namespace :cg do
  namespace :site do

    desc 'creates a new site'
    task :create => :environment do
      unless ENV['NAME']
        puts 'ERROR: site name required, use NAME=<name> to specify the name.'
        puts 'options: NETWORK=<name> DOMAIN=<domain> TITLE=<title> EMAIL=<email>'
        exit
      end
      if Site.find_by_name(ENV["NAME"])
        puts 'ERROR: a site with that name already exists.'
        exit
      end
      Site.create! :name => ENV["NAME"],
        :network => Network.find_by_name(ENV["NETWORK"]),
        :domain => ENV["DOMAIN"],
        :title => ENV["TITLE"],
        :email_sender => ENV["EMAIL"]
      puts 'Site "%s" created' % ENV["NAME"]
    end

    desc 'destroys a site'
    task :destroy => :environment do
      unless ENV['NAME']
        puts 'ERROR: site name required, use NAME=<name> to specify the name.'
        exit
      end
      site = Site.find_by_name(ENV["NAME"])
      unless site
        puts 'ERROR: no site found with name ""' % ENV["NAME"]
        exit
      end
      site.destroy
      puts 'Site "%s" destroyed' % ENV["NAME"]
    end

    desc 'list the sites in the database'
    task :list => :environment do
      puts "%15s%15s%15s" % ['name', 'domain', 'admin id']
      Site.find(:all, :order => 'name').each do |site|
        puts "%15s%15s%15s" % [site.name, site.domain, site.super_admin_group_id]
      end
    end

  end
end
