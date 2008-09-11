class ChangeProfileDefaults < ActiveRecord::Migration
  def self.up
    change_column_default(:profiles, :may_request_contact, true)
    change_column_default(:profiles, :may_pester, true)
    Profile.connection.execute "UPDATE profiles SET may_request_contact = 1 WHERE may_request_contact IS NULL"
    Profile.connection.execute "UPDATE profiles SET may_pester = 1 WHERE may_pester IS NULL"
  end

  def self.down
    # not reversable in any way
  end
end

