class AddModerationFlags < ActiveRecord::Migration
  def self.up
    self.really_up unless Page.columns.collect{|p| p.name}.include?("public_requested")
  end

  def self.really_up
    add_column :pages, :public_requested, :boolean, :default => false
    add_column :pages, :vetted, :boolean, :default => false
    add_column :pages, :yuck_count, :integer, :default => 0

    add_column :posts, :vetted, :boolean, :default => false
    add_column :posts, :yuck_count, :integer, :default => 0
  end

  def self.down
    remove_column :pages, :public_requested
    remove_column :pages, :vetted
    remove_column :pages, :yuck_count

    remove_column :posts, :vetted
    remove_column :posts, :yuck_count
  end
end

