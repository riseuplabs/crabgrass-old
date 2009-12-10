class AddPreferredEditorToUserSettings < ActiveRecord::Migration
  def self.up
    add_column :user_settings, :preferred_editor, :integer, :default => 0
  end

  def self.down
    remove_column :user_settings, :preferred_editor
  end
end
