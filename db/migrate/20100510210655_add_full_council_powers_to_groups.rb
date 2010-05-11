class AddFullCouncilPowersToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :full_council_powers, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :full_council_powers
  end
end
