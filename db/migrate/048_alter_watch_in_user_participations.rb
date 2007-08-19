class AlterWatchInUserParticipations < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `user_participations` ALTER COLUMN `watch` SET DEFAULT FALSE"
  end

  def self.down
    execute "ALTER TABLE `user_participations` ALTER COLUMN `watch` DROP DEFAULT"
  end
end
