class AlterWatchInUserParticipations < ActiveRecord::Migration
  def self.up
    change_column :user_participations, :watch, :boolean, :default => false
  end

  def self.down
    change_column :user_participations, :watch, :boolean
  end
end
