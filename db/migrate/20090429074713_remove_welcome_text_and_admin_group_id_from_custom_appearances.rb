class RemoveWelcomeTextAndAdminGroupIdFromCustomAppearances < ActiveRecord::Migration
  def self.up
    remove_column :custom_appearances, :welcome_text_title
    remove_column :custom_appearances, :welcome_text_body
    remove_column :custom_appearances, :admin_group_id
  end

  def self.down
    add_column :custom_appearances, :welcome_text_title, :string
    add_column :custom_appearances, :welcome_text_body, :text
    add_column :custom_appearances, :admin_group_id, :integer
  end
end
