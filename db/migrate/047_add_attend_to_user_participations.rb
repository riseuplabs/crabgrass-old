class AddAttendToUserParticipations < ActiveRecord::Migration
  def self.up
    add_column :user_participations, :attend, :boolean, :default => false
  end

  def self.down
    remove_column :user_participations, :attend
  end
end

