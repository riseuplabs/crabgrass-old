class MakePagesStarsCountDefaultTo0 < ActiveRecord::Migration
  def self.up
    change_column :pages, :stars_count, :integer, :default => 0
    change_column :page_terms, :stars_count, :integer, :default => 0
  end

  def self.down
    change_column :pages, :stars_count, :integer
    change_column :page_terms, :stars_count, :integer
  end
end
