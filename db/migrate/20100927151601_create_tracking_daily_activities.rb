class CreateTrackingDailyActivities < ActiveRecord::Migration
  def self.up
    create_table :tracking_daily_activities do |t|
      t.integer :count
      t.integer :user_id

      t.timestamps
    end
    Tracking::DailyActivity.update
  end

  def self.down
    drop_table :tracking_daily_activities
  end
end
