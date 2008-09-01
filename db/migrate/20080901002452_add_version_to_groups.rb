class AddVersionToGroups < ActiveRecord::Migration
  def self.up
   add_column :groups, :version, :integer, :default => 0, :unsigned => true
  end

  def self.down
   remove_column :groups, :version
  end
end
