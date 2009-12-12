class RemoveStiFromModeratedFlags < ActiveRecord::Migration

  def self.up
    remove_column :moderated_flags, :type
  end

  def self.down
    add_column :moderated_flags, :type, :integer
  end

end
