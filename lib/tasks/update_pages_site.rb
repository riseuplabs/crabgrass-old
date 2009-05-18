#
# This task is for legacy data created before sites. It assigns
# site_id to things that need to have site_id.
#
# You must run rake cg:update_page_terms after
#

namespace :cg do

  desc "improves site_id for pages with multiple users, if possible"
  task(:update_pages_site => :environment) do

    Page.find(:all, :conditions => 'owner_type IS "User"').each do |page|
      site_id = find_site_id_for_page(page)
      if site_id and site_id != 0
        puts "page(%s).site_id = %s" % [page.id, site_id]
        Page.connection.execute "UPDATE pages SET site_id = #{site_id} WHERE id = #{page.id}"
      else
        puts "page(%s) could not get a site_id assigned." % page.id
      end
    end
  end
end

def find_site_id_for_page(page)
  site_id = nil
  if page.owner and page.owner.sites.count != 1
    groups = page.groups
    users = page.users
    return groups.first.site_id if groups.any?
    users.each do |user|
      if user.sites.count == 1
        site_id = user.site_id if site_id == nil
        return 0 if site_id != user.site_id  # conflicting sites for this page
      end
    end
  end
  site_id
end
