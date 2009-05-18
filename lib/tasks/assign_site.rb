#
# This task is for legacy data created before sites. It assigns
# site_id to things that need to have site_id.
# 
# You must run rake cg:update_page_terms after
# 
namespace :cg do

  desc "sets site_id for every page, if possible"
  task(:assign_sites => :environment) do 
    site_ids = {}  # group_id ==> site_id
    Site.find(:all).each do |site|
      if site.network_id
        site_ids[site.network_id] = site.id
        site.network.groups.each do |group|
          site_ids[group.id] = site.id
          group.committees.each do |committee|
            site_ids[committee.id] = site.id
          end
        end
      end
    end

    Group.find(:all, :conditions => 'site_id IS NULL').each do |group|
      if site_ids[group.id]
        site_id = site_ids[group.id]
        puts "group(%s).site_id = %s" % [group.id, site_id]
        Group.connection.execute "UPDATE groups SET site_id = #{site_id} WHERE id = #{group.id}"
      end
    end

    Page.find(:all, :conditions => 'site_id IS NULL').each do |page|
      if page.owner and page.owner.site_id and (page.owner.is_a? Group or page.owner.sites.count == 1)
        site_id = page.owner.site_id
        puts "page(%s).site_id = %s" % [page.id, site_id]
        Page.connection.execute "UPDATE pages SET site_id = #{site_id} WHERE id = #{page.id}"
      elsif page.owner and page.owner.is_a? User
        groups = page.groups
        users = page.users
        if groups.any?
          site_id = groups.first.site_id
          if site_id
            puts "page(%s).site_id = %s" % [page.id, site_id]
            Page.connection.execute "UPDATE pages SET site_id = #{site_id} WHERE id = #{page.id}"
          end
        elsif users.any?
          users.each do |user|
            if user.sites.count == 1
              if site_id == nil
                site_id = user.site_id
              elsif site_id != user.site_id
                site_id = 0
              end
            end
          end
          if site_id and site_id != 0
            puts "page(%s).site_id = %s" % [page.id, site_id]
            Page.connection.execute "UPDATE pages SET site_id = #{site_id} WHERE id = #{page.id}"
          end
        end
      end
    end

    Activity.find(:all, :conditions => 'site_id IS NULL').each do |activity|
      site_id = activity.object.site_id if activity.object and activity.object.respond_to?(:site_id)
      site_id = activity.subject.site_id if activity.subject and activity.subject.respond_to?(:site_id)
      if site_id
        puts "activity(%s).site_id = %s" % [activity.id, site_id]
        Activity.connection.execute "UPDATE activities SET site_id = #{site_id} WHERE id = #{activity.id}"
      end
    end

    Request.find(:all, :conditions => 'site_id IS NULL').each do |request|
      site_id = request.recipient.site_id if request.recipient and request.recipient.respond_to?(:site_id)
      site_id = request.requestable.site_id if request.requestable and request.requestable.respond_to?(:site_id)
      if site_id
        puts "request(%s).site_id = %s" % [request.id, site_id]
        Request.connection.execute "UPDATE activities SET site_id = #{site_id} WHERE id = #{request.id}"
      end
    end

  end


end
