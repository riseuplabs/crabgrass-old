# lots of MySQL-specific stuff here.
class Daily < ActiveRecord::Base
  belongs_to :page

  def self.update
    begin
      connection.execute("LOCK TABLES hourlies WRITE, dailies WRITE")
      connection.execute("DELETE QUICK FROM dailies WHERE created_at < NOW() - INTERVAL 30 DAY")
      connection.execute("INSERT DELAYED INTO dailies (page_id, views, stars, edits, created_at)
        SELECT hourlies.page_id, sum(hourlies.views), sum(hourlies.stars), sum(hourlies.edits), now() - INTERVAL 1 DAY
        FROM hourlies
        GROUP BY hourlies.page_id")
    ensure
      connection.execute("UNLOCK TABLES")
    end
    true
  end
end
