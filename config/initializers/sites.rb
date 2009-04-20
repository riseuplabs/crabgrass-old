#
#
# Sites are stored in the db, but the crabgrass.*.yml file determines which sites
# are active and what the admin group is for each site. This is kept in the config
# file for security reasons and to make it easy to enable/disable sites.
#

ids = []
begin
  Conf.sites.each do |site_conf|
    site = Site.find_by_name(site_conf['name'])
    if site
      admin_group = Group.find_by_name(site_conf['admin_group'])
      if admin_group
        site.update_attribute(:super_admin_group_id, admin_group.id)
        ids << site.id
      else
        puts "ERROR (%s): site admin group name '%s' not found in database! (skipping site)" % [Conf.configuration_filename, site_conf['admin_group']]
      end
    else
      if Site.count == 0
        puts 'Skipping site configuration: database has no sites.'
        raise Exception.new('skip sites')
      else
        puts "ERROR (%s): site name '%s' not found in database!" % [Conf.configuration_filename,site_conf['name']]
        puts "Available site names are:"
        puts "  " + Site.find(:all).collect{|s|s.name}.inspect
        puts "To create a site, run:\n  rake cg:site:create NAME=<name> RAILS_ENV=<env>"
      end
    end
  end
rescue Exception => exc
  # skip the sites initialization if something goes wrong. Likely, the problem is
  # that the sites db is not yet set up.
end

# an array of id numbers of sites that are enabled. If a site does not
# have an id in this array, then we pretend that the site doesn't exist.
SITES_ENABLED = ids.freeze

