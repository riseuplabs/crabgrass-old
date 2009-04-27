class AddMembershipsSeen < ActiveRecord::Migration
  def self.up
    add_column :memberships, :seen, :text
  end

  def self.down
    remove_column :memberships, :seen
  end
end
