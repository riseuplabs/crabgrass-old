class AddCountToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :contributors_count, :integer, :default => 0
    add_column :pages, :posts_count, :integer, :default => 0
    Page.find(:all).each do |page|
      page.contributors_count = page.contributors.size
      page.save
    end
    
  end

  def self.down
    remove_column :pages, :contributors_count
    remove_column :pages, :posts_count
  end
end
