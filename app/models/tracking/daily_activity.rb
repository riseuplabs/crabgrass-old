class Tracking::DailyActivity < ActiveRecord::Base
  belongs_to :user

  def self.update

    connection.execute("INSERT DELAYED INTO tracking_daily_activities (user_id, count, created_at)
      SELECT user_id, count(*), DATE(changed_at) as date
      FROM user_participations WHERE DATE(changed_at) < DATE(UTC_TIMESTAMP() - INTERVAL 1 DAY)
      GROUP BY user_id, date")
  end

end
