class AddInboxFlagToUserParticipations < ActiveRecord::Migration
  def self.up
    add_column :user_participations, :inbox, :boolean, :default => true
  end

  def self.down
    remove_column :user_participations, :inbox
  end
end
