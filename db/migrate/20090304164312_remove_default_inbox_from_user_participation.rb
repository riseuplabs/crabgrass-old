class RemoveDefaultInboxFromUserParticipation < ActiveRecord::Migration
  def self.up
    change_column :user_participations, :inbox, :boolean, :default => false
  end

  def self.down
    change_column :user_participations, :inbox, :boolean, :default => true
  end
end
