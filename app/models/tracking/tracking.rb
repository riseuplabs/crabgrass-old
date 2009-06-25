# um, so, yeah, basically we don't use ActiveRecord for this.
# lots of MySQL-specific stuff here.
class Tracking < ActiveRecord::Base
  belongs_to :page
  belongs_to :group
  belongs_to :user

  @@seen_users=Set.new

  # Tracks the actions quickly. Following things can be tracked:
  # :user - user that was doing anything
  # :action - one of :view, :edit, :star
  # :page - page that this happened on
  # :group - group context
  def self.insert_delayed(things={})
    connection.execute("INSERT DELAYED INTO #{table_name}
                       (page_id, group_id, user_id, action_id, tracked_at)
                       VALUES (#{quoted_id(things[:page])},
                               #{quoted_id(things[:group])},
                               #{quoted_id(things[:user])},
                               #{ACTION[things[:action]]|| 1},
                               NOW() )")
    true
  end

  def self.saw_user(user_id)
    @@seen_users << user_id
    true
  end
  ##
  ## Sets last_seen for users that were active in the last 5 minutes.
  ##
  def self.update_last_seen_users
    connection.execute("UPDATE users,#{table_name}
                       SET users.last_seen_at = NOW() - INTERVAL 1 MINUTE
                       WHERE users.id IN (#{@@seen_users.to_a.join(', ')})")
    @@seen_users.clear
    true
  end


  ##
  ## Takes all the page view records that have been inserted into trackings
  ## table and updates the view counts in the hourlies and membership tables with
  ## this data. Afterward, all the data in trackings table is deleted.
  ##

  def self.process
    begin
      connection.execute("LOCK TABLES #{table_name} WRITE, hourlies WRITE, memberships WRITE")
      connection.execute("DELETE QUICK FROM hourlies WHERE created_at < NOW() - INTERVAL 1 DAY")
      connection.execute("INSERT INTO hourlies
                           (page_id, views, ratings, edits, created_at)
                         SELECT page_id, COUNT(*) AS c, NULL, NULL, now()
                           FROM #{table_name} GROUP BY page_id")

      connection.execute("CREATE TEMPORARY TABLE group_view_counts
                         SELECT COUNT(*) AS c, user_id, group_id, MAX(tracked_at) as tracked_at
                         FROM #{table_name} GROUP BY user_id, group_id")
      connection.execute("UPDATE memberships, group_view_counts
                         SET memberships.visited_at = group_view_counts.tracked_at,
                           memberships.total_visits = memberships.total_visits + group_view_counts.c
                         WHERE memberships.user_id = group_view_counts.user_id AND
                           memberships.group_id = group_view_counts.group_id")
      connection.execute("DROP TEMPORARY TABLE group_view_counts")

      self.delete_all
    ensure
      connection.execute("UNLOCK TABLES")
    end
    # do this after unlocking tables just to try to minimize the amount of time tables are locked…
    connection.execute("UPDATE page_terms,hourlies
                       SET page_terms.views_count = page_terms.views_count + hourlies.views
                       WHERE page_terms.id=hourlies.page_id AND hourlies.created_at > NOW() - INTERVAL 30 MINUTE")
    connection.execute("UPDATE page_terms,pages
                       SET pages.views_count = page_terms.views_count
                       WHERE pages.id=page_terms.page_id")
    true
  end

  def self.quoted_id(thing)
    connection.quote(id_from(thing))
  end

  def self.id_from(thing)
    if thing
      thing.is_a?(Fixnum) ?
        thing :
        thing.id
    end
  end
end
