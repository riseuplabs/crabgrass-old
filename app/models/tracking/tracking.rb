# um, so, yeah, basically we don't use ActiveRecord for this.
# lots of MySQL-specific stuff here.
class Tracking < ActiveRecord::Base
  #belongs_to :page
  #belongs_to :group
  #belongs_to :user

  # Tracks the actions quickly. Following things can be tracked:
  # :current_user - user that was doing anything
  # :action       - one of :view, :edit, :star
  # :page         - page that this happened on
  # :group        - group context
  # :user         - user context
  def self.insert_delayed(things={})
    return false if things.empty?
    delayed = RAILS_ENV == 'test' ? '' : 'DELAYED' # don't delay if testing
    execute(%(
      INSERT #{delayed} INTO trackings(current_user_id, page_id, group_id, user_id, views, edits, stars, tracked_at)
      VALUES (#{values_for_tracking(things).join(', ')})
    ))
    true
  end

  ##
  ## Takes all the page view records that have been inserted into trackings
  ## table and updates the view counts in the hourlies and membership tables with
  ## this data. Afterward, all the data in trackings table is deleted.
  ##

  def self.process
    return if (Tracking.count == 0)

    unprocessed_since = last_processed_at

    lock_tables do

      ##
      ## update hourlies
      ##

      # TODO: include edit counts in normal trackings to avoid the LEFT JOIN --azul
      execute(%(
        INSERT INTO hourlies (page_id, views, stars, edits, created_at)
        SELECT trackings.page_id, trackings.view_count, trackings.star_count,
               participations.contributor_count,
               TIMESTAMPADD(HOUR, trackings.hour + 1, trackings.date)
        FROM (
          SELECT page_id, SUM(views) AS view_count, SUM(stars) AS star_count,
                 DATE(tracked_at) AS date, HOUR(tracked_at) AS hour
          FROM trackings
          GROUP BY page_id, date, hour
        ) AS trackings
        LEFT JOIN(
          SELECT page_id, COUNT(*) as contributor_count, DATE(changed_at) as date,
                 HOUR(changed_at) as hour
          FROM user_participations
          WHERE (user_participations.changed_at > '#{unprocessed_since.to_s(:db)}')
          GROUP BY page_id, date, hour
        ) AS participations
        ON trackings.page_id = participations.page_id AND
           trackings.date = participations.date AND
           trackings.hour = participations.hour
      ))

      ##
      ## update memberships visit count
      ##

      execute(%(
        CREATE TEMPORARY TABLE group_view_counts
        SELECT COUNT(*) AS c, current_user_id, group_id, MAX(tracked_at) as tracked_at
        FROM trackings GROUP BY current_user_id, group_id
      ))
      execute(%(
        UPDATE memberships, group_view_counts
        SET memberships.visited_at = group_view_counts.tracked_at,
            memberships.total_visits = memberships.total_visits + group_view_counts.c
        WHERE memberships.user_id = group_view_counts.current_user_id AND
              memberships.group_id = group_view_counts.group_id
      ))
      execute(%(DROP TEMPORARY TABLE group_view_counts))

      ##
      ## update relationships visit count
      ##

      execute(%(
        CREATE TEMPORARY TABLE user_view_counts
        SELECT COUNT(*) AS c, user_id, current_user_id, MAX(tracked_at) as tracked_at
        FROM trackings GROUP BY user_id, current_user_id
      ))
      execute(%(
        UPDATE relationships, user_view_counts
        SET relationships.visited_at = user_view_counts.tracked_at,
            relationships.total_visits = relationships.total_visits + user_view_counts.c
        WHERE relationships.user_id = user_view_counts.current_user_id AND
              relationships.contact_id = user_view_counts.user_id
      ))
      execute(%(DROP TEMPORARY TABLE user_view_counts))

      self.delete_all
    end

    # do this after unlocking tables just to try to minimize the amount of time tables are locked

    ##
    ## update page_terms
    ##

    execute(%(
      UPDATE page_terms,hourlies
      SET page_terms.views_count = page_terms.views_count + hourlies.views
      WHERE page_terms.page_id=hourlies.page_id AND
            hourlies.created_at > '#{unprocessed_since.to_s(:db)}' + INTERVAL 30 MINUTE
    ))

    ##
    ## update pages
    ##

    execute(%(
      UPDATE page_terms,pages
      SET pages.views_count = page_terms.views_count
      WHERE pages.id=page_terms.page_id
    ))

    true
  end

  protected

  # returns an array of (page_id, group_id, user_id, views, edits, stars, tracked_at)
  # for use in mysql values
  def self.values_for_tracking(things)
    views = things[:action] == :view ? 1 : 0
    edits = things[:action] == :edit ? 1 : 0
    stars = things[:action] == :star ? 1 : 0
    stars -= things[:action] == :unstar ? 1 : 0
    # for testing we need to be able to create old trackings...
    time = things[:time] || Time.now.utc
    time = connection.quote time.to_s(:db)
    thing_ids = things.values_at(:current_user, :page, :group, :user).collect{|t| quoted_id(t)}
    thing_ids.concat [views, edits, stars, time]
  end

  def self.quoted_id(thing)
    connection.quote(id_from(thing))
  end

  def self.id_from(thing)
    if thing.nil?
      nil
    elsif thing.is_a?(Fixnum)
      thing
    elsif thing.is_a?(ActiveRecord::Base)
      thing.id
    else
      nil
    end
  end

  def self.execute(sql)
    connection.execute(sql)
  end

  def self.lock_tables(&block)
    begin
      execute("LOCK TABLES trackings WRITE, hourlies WRITE, memberships WRITE, relationships WRITE, user_participations WRITE")
      yield
    ensure
      execute("UNLOCK TABLES")
    end
  end

  def self.last_processed_at
    Tracking.find(:first, :order => :tracked_at).tracked_at || Time.now - 3.month
  end

end
