class AddModerationFlagsToChatMessage < ActiveRecord::Migration

  def self.up
    add_column :messages, :yuck_count, :integer, :default => 0
    add_column :messages, :vetted, :boolean, :default => false
  end

  def self.down
    remove_column :messages, :yuck_count
    remove_column :messages, :vetted
  end
end
