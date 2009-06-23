# um, so, yeah, basically we don't use ActiveRecord for this.
# lots of MySQL-specific stuff here.
class Tracking < ActiveRecord::Base
  belongs_to :page
  belongs_to :group
  belongs_to :user
  
  def self.insert_delayed(things={})
    page_or_id  = things[:page]
    group_or_id = things[:group]
    user_or_id  = things[:user]
    page_id  = (page_or_id.is_a?(Fixnum)  ? page_or_id  : page_or_id.id)  if page_or_id
    group_id = (group_or_id.is_a?(Fixnum) ? group_or_id : group_or_id.id) if group_or_id
    user_id  = (user_or_id.is_a?(User) ? user_or_id.id  : user_or_id)  if user_or_id
    connection.execute("INSERT DELAYED INTO #{table_name} (page_id, group_id, user_id, tracked_at) VALUES (#{connection.quote(page_id)}, #{connection.quote(group_id)}, #{connection.quote(user_id)}, NOW() )")
  end
  
  ##
  ## Takes all the page view records that have been inserted into trackings
  ## table and updates the view counts in the hourlies and dailies tables with
  ## this data. Afterward, all the data in the page_views table is deleted.
  ##
    
  def self.update_trackings
    begin
      connection.execute("LOCK TABLES #{table_name} WRITE, hourlies WRITE, memberships WRITE")
      connection.execute("DELETE QUICK FROM hourlies WHERE created_at < NOW() - INTERVAL 1 DAY")
      connection.execute("INSERT DELAYED INTO hourlies (page_id, views, ratings, edits, created_at) SELECT page_id, COUNT(*) AS c, NULL, NULL, now() FROM #{table_name} GROUP BY page_id")

      connection.execute("CREATE TEMPORARY TABLE group_view_counts SELECT COUNT(*) AS c, user_id, group_id, MAX(tracked_at) as tracked_at FROM #{table_name} GROUP BY user_id, group_id")
      connection.execute("UPDATE memberships, group_view_counts SET memberships.visited_at = group_view_counts.tracked_at, memberships.total_visits = memberships.total_visits + group_view_counts.c WHERE memberships.user_id = group_view_counts.user_id and memberships.group_id = group_view_counts.group_id")
      connection.execute("DROP TEMPORARY TABLE group_view_counts")
      
      self.delete_all
    ensure
      connection.execute("UNLOCK TABLES")
    end
    # do this after unlocking tables just to try to minimize the amount of time tables are locked…
    connection.execute("UPDATE page_terms,hourlies SET page_terms.views_count = page_terms.views_count + hourlies.views WHERE page_terms.id=hourlies.page_id AND hourlies.created_at > NOW() - INTERVAL 30 MINUTE")
    connection.execute("UPDATE page_terms,pages SET pages.views_count = page_terms.views_count WHERE pages.id=page_terms.page_id")
    true
  end

  def self.update_dailies
    begin
      connection.execute("LOCK TABLES hourlies WRITE, dailies WRITE")
      connection.execute("DELETE QUICK FROM dailies WHERE created_at < NOW() - INTERVAL 30 DAY")
      connection.execute("INSERT DELAYED INTO dailies (page_id, views, created_at)
        SELECT hourlies.page_id, sum(hourlies.views), now() - INTERVAL 1 DAY
        FROM hourlies
        GROUP BY hourlies.page_id")
    ensure
      connection.execute("UNLOCK TABLES")
    end
  end
end
