#
# contributors_count was busted before. this migration will make sure that 
# the database uses good data from here on out.
#
class UpdatePageContributorsCount < ActiveRecord::Migration
  def self.up
    conn = Page.connection
    conn.select_values('select id from pages').each do |page_id|
      count = conn.select_value("select count(*) from user_participations where user_participations.page_id = #{page_id} and changed_at IS NOT NULL")
      conn.execute "update pages set contributors_count = #{count} where id = #{page_id}"
    end
  end

  def self.down
  end
end
