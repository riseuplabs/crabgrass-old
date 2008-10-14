class AddPagesStars < ActiveRecord::Migration
  def self.up
    add_column :pages, :stars, :integer, :default => 0
  end

  def self.down
    remove_column :pages, :stars
  end
end
