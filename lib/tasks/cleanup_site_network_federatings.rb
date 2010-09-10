=begin

We do not use Site Network Membership anymore to determine
which site a group is on. Groups now are acting as site limited.
This means 2 things:
 a) they should have the site id set.
 b) the old federatings should be removed so we don't have to hide them
=end

def self.ensure_site_id_set
  sql = <<EOSQL
UPDATE groups, sites, federatings
SET groups.site_id=sites.id
WHERE groups.id = federatings.group_id
AND sites.network_id = federatings.network_id
EOSQL
  ActiveRecord::Base.connection.execute(sql)
end

def self.remove_federatings_with_site_networks
  sql = <<EOSQL
DELETE federatings
FROM federatings, sites
WHERE sites.network_id = federatings.network_id
EOSQL
  ActiveRecord::Base.connection.execute(sql)
end

def self.fail_group_on_multiple_sites(group_ids)
  puts  <<EOERR
ERROR: Some groups exist on two sites.
This can not be modeled with the new groups acting as site limited.
Please fix this by hand by removing the federatings with all but
one site network for the following groups:
EOERR
  group_id_occurances = group_ids.inject({}) do |h,v|
  h[v] = h[v].to_i + 1
  h
  end
  dup_group_ids = group_id_occurances.reject{|k,v| v==1}.keys
  dup_groups = Group.find :all,
    :conditions => "id IN (#{dup_group_ids.compact.join(',')})"
  puts dup_groups[0...4].map(&:name).join(", ")
  if dup_groups.count > 5
    puts "... and #{dup_groups.count -5} other groups."
  end
  exit 1
end

namespace :cg do
  desc "removes federatings with site networks - they are not needed anymore."
  task(:cleanup_site_networks => :environment) do
    site_network_ids = Site.all.map(&:network_id)
    exit unless site_network_ids.any?
    federatings = Federating.find :all,
      :conditions => "network_id IN (#{site_network_ids.compact.join(',')})"
    group_ids = federatings.map(&:group_id)

    if group_ids.uniq.count != federatings.count
      fail_group_on_multiple_sites(group_ids)
    end
    count = federatings.count
    sample = federatings.first

    ensure_site_id_set
    remove_federatings_with_site_networks
  end
end

