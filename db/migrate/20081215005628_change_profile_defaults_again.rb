class ChangeProfileDefaultsAgain < ActiveRecord::Migration
  def self.up
    change_column_default(:profiles, :may_see, true)
    Profile.connection.execute "UPDATE profiles SET may_see = 1 WHERE may_see IS NULL"
  end

  def self.down
    # can't be undone
  end
end
