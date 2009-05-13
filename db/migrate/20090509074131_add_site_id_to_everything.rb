class AddSiteIdToEverything < ActiveRecord::Migration
  def self.up
    add_column :pages, :site_id, :integer
    add_column :activities, :site_id, :integer
    add_column :requests, :site_id, :integer
  end

  def self.down
    remove_column :pages, :site_id
    remove_column :activities, :site_id
    remove_column :requests, :site_id
  end
end

