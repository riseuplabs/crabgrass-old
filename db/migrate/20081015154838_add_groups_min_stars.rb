class AddGroupsMinStars < ActiveRecord::Migration
  def self.up
    add_column :groups, :min_stars, :integer, :default => 1
  end

  def self.down
    remove_column :groups, :min_stars
  end
end
