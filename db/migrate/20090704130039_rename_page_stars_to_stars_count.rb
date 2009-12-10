class RenamePageStarsToStarsCount < ActiveRecord::Migration
  def self.up
    rename_column :pages, :stars, :stars_count
    rename_column :page_terms, :stars, :stars_count
  end

  def self.down
    rename_column :pages, :stars_count, :stars
    rename_column :page_terms, :stars_count, :stars
  end
end
