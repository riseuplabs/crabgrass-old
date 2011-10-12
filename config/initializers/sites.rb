#
#
# Sites are stored in the db, but the crabgrass.*.yml file determines which sites
# are active and what the admin group is for each site. This is kept in the config
# file for security reasons and to make it easy to enable/disable sites.
#

if Site.count == 0
  puts 'Skipping site configuration: database has no sites.'
else
  ids = Site.load_all_from_config(Conf.sites)
  # an array of id numbers of sites that are enabled. If a site does not
  # have an id in this array, then we pretend that the site doesn't exist.
  Conf.enabled_site_ids = ids.freeze
end
