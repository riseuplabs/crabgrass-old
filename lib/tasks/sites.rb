namespace :cg do
  namespace :site do

    SITE_OPTIONS = %w[domain title email_sender default limited
      pagination_size default_language enforce_ssl show_exceptions tracking]

    def react(message)
      puts message unless ENV["QUIET"]
      yield if block_given? and ENV["FIX"]
    end

    def check_for_name!
      unless name = ENV['NAME']
        raise 'Site name required, use NAME=<name> to specify the name.'
      end
      name
    end

    def verify_site_options(site, site_conf)
      site_conf.slice(SITE_OPTIONS).each do |option, value|
        option = option.to_sym
        current = site.send(option)
        if current and value != current
          # we set the value if FILL is specified. nil will lead to the
          # value being read from the conf file.
          fill = ENV['FILL'] ? value : nil
          site.write_attribute option, fill
        end
      end
      return site
    end

    def verify_group_type(site, site_conf, group_type)
      group_name=site_conf[group_type]
      group_type = "super_admin_group" if group_type == "admin_group"
      if group = site.send(group_type.to_sym)
        old_group=group
        verify_group_name(group, group_name)
        group=verify_group_site(group, site)
      elsif group = Group.find_by_name(group_name)
        group=verify_group_site(group, site)
      elsif group_name
        react "#{group_type}: #{group_name} does not exist... creating"
        if group_type == 'network'
          group = Network.new :name=>group_name, :site=>site
          site.network = group
        else
          group = Group.new :name=>group_name, :site=>site
        end
      else
        react "WARNING: no #{group_type} set."
      end
      verify_group_admin(group)
      finalize(group, old_group)
      return site
    end

    def verify_group_name(group, group_name)
      if group.name != group_name
        react "WARNING: group is set to #{group_name} in config."
        react "                  and to #{group.name} in database."
      end
    end

    def verify_group_site(group, site)
      # what happens if site does not exist because we are in testing mode?
      return unless site.limited? and group.site_id != site.id
      react "#{group.name} does not belong to site yet."
      unless group.site_id
        react "Attaching to site..."
        group.site = site
      else
        raise "#{group.name} belongs to a different site. Aborting..."
      end
      return group
    end

    def verify_group_admin(group)
      admin = User.find_by_login ENV['ADMIN']
      return unless group and admin
      return if group.users.include?(admin)
      react "#{group.name} does not include admin #{admin.login}..." do
        react "... adding to group."
        group.save!
        group.add_user! admin
      end
    end

    # either print or save depending on the mode.
    def finalize(object, old_object = nil)
      if object.nil?
        type = old_object.nil? ? "object" : old_object.type
        react "WARNING: no #{type} given - cannot save."
        return
      end
      act = object.new_record? ? "be created" : "be updated"
      diff = attr_diff(object, old_object)
      unless diff.empty?
        react "  The #{object.type} #{object.name} will #{act} like this:"
      end
      react "#{attr_diff(object, old_object)}" do
        object.save!
        react "  ... done."
      end
    end

    def attr_diff(object, old_obj)
      old_obj ||= {}
      ret = ""
      object.attributes.select{|a,b| b != old_obj[a]}.each do |key,value|
        ret << "  #{key}: #{value} (#{old_obj[key]})\n"
      end
      ret
    end

    desc 'creates a new site'
    task :create => :environment do
      unless name = ENV['NAME']
        puts 'ERROR: site name required, use NAME=<name> to specify the name.'
        react 'options: NETWORK=<name> DOMAIN=<domain> TITLE=<title> EMAIL=<email>'
        exit
      end
      if Site.find_by_name name
        raise 'A site with that name already exists.'
      end
      Site.create! :name => name,
        :network => Network.find_by_name(ENV["NETWORK"]),
        :domain => ENV["DOMAIN"],
        :title => ENV["TITLE"],
        :email_sender => ENV["EMAIL"]
      puts 'Site "%s" created' % name
    end

    # this task only creates the very basic settings. Other settings will be
    # created as nil. For nil values cg will use the config file. This way the
    # config values can later be overwritten in the config itself.
    desc 'creates sites with networks from the config'
    task :create_from_config => :environment do
      name = check_for_name!
      unless site_conf = Conf.sites.find{|s| s['name'] == name}
        raise "Site #{name} not specified in config for #{ENV['RAILS_ENV']}."
      end
      if ENV['ADMIN'] and not admin=User.find_by_login(ENV['ADMIN'])
        raise "Admin #{ENV['ADMIN']} does not exist. Please create admin first."
      end
      puts "checking site #{site_conf['name']}..."
      if site = Site.find_by_name(site_conf['name'])
        old_site = site
        site = verify_site_options(site, site_conf)
      else
        puts "  site does not exist yet... creating"
        site = Site.new :name=>site_conf['name'],
          :limited => site_conf['limited'] || Conf.limited || true
      end
      ['moderation_group','admin_group', 'network'].each do |group_type|
        group = verify_group_type(site, site_conf, group_type)
      end
      finalize(site, old_site)
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
