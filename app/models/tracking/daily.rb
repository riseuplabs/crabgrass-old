# lots of MySQL-specific stuff here.
class Daily < ActiveRecord::Base
  belongs_to :page

  def self.update
    begin
      # this should not depend on being run every 24 hours because
      # the background process can crash.
      connection.execute("LOCK TABLES hourlies WRITE, dailies WRITE")
      connection.execute("DELETE QUICK FROM dailies WHERE created_at < NOW() - INTERVAL 30 DAY")
      connection.execute("INSERT DELAYED INTO dailies (page_id, views, stars, edits, created_at)
        SELECT hourlies.page_id, sum(hourlies.views), sum(hourlies.stars), sum(hourlies.edits), DATE(hourlies.created_at) as date
        FROM hourlies WHERE DATE(created_at) < DATE(UTC_TIMESTAMP() - INTERVAL 1 DAY)
        GROUP BY hourlies.page_id, date")
      # now that we can be sure that all hourlies have been processed we can remove the
      # old ones.
      # The WHERE condition here matches the one above to make sure we do not count twice.
      connection.execute("DELETE QUICK FROM hourlies WHERE DATE(created_at) < DATE(UTC_TIMESTAMP() - INTERVAL 1 DAY)")
    ensure
      connection.execute("UNLOCK TABLES")
    end
    true
  end
end
