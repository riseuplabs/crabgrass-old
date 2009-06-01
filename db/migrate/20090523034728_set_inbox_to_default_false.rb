class SetInboxToDefaultFalse < ActiveRecord::Migration
  def self.up
    change_column_default(:user_participations, :inbox, false)
  end

  def self.down
    change_column_default(:user_participations, :inbox, true)
  end
end
