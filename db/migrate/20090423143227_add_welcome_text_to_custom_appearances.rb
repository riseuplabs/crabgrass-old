class AddWelcomeTextToCustomAppearances < ActiveRecord::Migration
  def self.up
    add_column :custom_appearances, :welcome_text_title, :string
    add_column :custom_appearances, :welcome_text_body, :text    
  end

  def self.down
    remove_column :custom_appearances, :welcome_text_title
    remove_column :custom_appearances, :welcome_text_body
  end
end
