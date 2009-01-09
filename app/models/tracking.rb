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
    connection.execute("INSERT DELAYED INTO #{table_name} (page_id, group_id, user_id, tracked_at) VALUES (#{connection.quote(page_id)}, #{connection.quote(group_id)}, #{connection.quote(user_id)}, now() )")
  end
  
  ##
  ## Takes all the page view records that have been inserted into page_views
  ## table and updates the view counts in the pages and page_terms tables with
  ## this data. Afterward, all the data in the page_views table is deleted.
  ##
    
  def self.update_trackings
    begin
      connection.execute("LOCK TABLES #{table_name} WRITE, page_terms WRITE, memberships WRITE")
      connection.execute("CREATE TEMPORARY TABLE page_view_counts SELECT COUNT(*) AS c, page_id FROM #{table_name} GROUP BY page_id")
      connection.execute("UPDATE page_terms,page_view_counts SET page_terms.views_count = page_terms.views_count + page_view_counts.c WHERE page_terms.page_id = page_view_counts.page_id")
      connection.execute("DROP TEMPORARY TABLE page_view_counts")
 
      connection.execute("CREATE TEMPORARY TABLE group_view_counts SELECT COUNT(*) AS c, user_id, group_id, MAX(tracked_at) as tracked_at FROM #{table_name} GROUP BY user_id, group_id")
      connection.execute("UPDATE memberships, group_view_counts SET memberships.visited_at = group_view_counts.tracked_at, memberships.total_visits = memberships.total_visits + group_view_counts.c WHERE memberships.user_id = group_view_counts.user_id and memberships.group_id = group_view_counts.group_id")
      connection.execute("DROP TEMPORARY TABLE group_view_counts")
      
      self.delete_all
    ensure
      connection.execute("UNLOCK TABLES")
    end
    # do this after unlocking tables just to try to minimize the amount of time tables are locked…
    connection.execute("UPDATE page_terms,pages SET pages.views_count = page_terms.views_count WHERE pages.id=page_terms.page_id")
    
    true
  end
end
