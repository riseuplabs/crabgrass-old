class RemoveIsCouncil < ActiveRecord::Migration
  def self.up
    Group.connection.execute("
      UPDATE `groups`
      SET `type` = 'Council'
      WHERE `is_council` = 1
    ")
    remove_column :groups, :is_council
  end

  def self.down
    add_column :groups, :is_council, :boolean, :default => false
    Group.connection.execute("
      UPDATE `groups`
      SET `is_council` = 1
      WHERE `type` = 'Council'
    ")
  end
end
