class AddAttendingToUserParticipations < ActiveRecord::Migration
  def self.up
    add_column :user_participations, :attending, :boolean, :default => false
  end

  def self.down
    remove_column :user_participations, :attending
  end
end

