class AddModerationFlags < ActiveRecord::Migration

  # This migration has caused quite some trouble. It was moved over from
  # superadmin mod. So on some installs it has already happened as part
  # of superadmin but rails can't tell because now its part of moderation.
  # So we first check if it has been run already and only run if it has not.
  def self.up
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

