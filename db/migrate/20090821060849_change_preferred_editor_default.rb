class ChangePreferredEditorDefault < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `user_settings` MODIFY COLUMN `preferred_editor` TINYINT DEFAULT NULL;"
  end

  def self.down
    change_column_default(:user_settings, :preferred_editor, 0)
  end
end
