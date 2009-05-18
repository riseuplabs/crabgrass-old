class AddPublicPagesToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :public_pages, :string
  end

  def self.down
    remove_column :pages, :public_pages
  end
end
