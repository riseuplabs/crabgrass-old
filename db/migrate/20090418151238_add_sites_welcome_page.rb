class AddSitesWelcomePage < ActiveRecord::Migration
  def self.up
    add_column :sites, :welcome_page, :string
  end

  def self.down
    remove_column :sites, :welcome_page
  end
end
