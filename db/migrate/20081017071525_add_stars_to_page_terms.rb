class AddStarsToPageTerms < ActiveRecord::Migration
  def self.up
    add_column :page_terms, :stars, :integer, :default => 0
  end

  def self.down
    remove_column :page_terms, :stars
  end
end

