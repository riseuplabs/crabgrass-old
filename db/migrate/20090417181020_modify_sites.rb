class ModifySites < ActiveRecord::Migration
  def self.up
    add_column :sites, :title, :string
    add_column :sites, :enforce_ssl, :boolean
    add_column :sites, :show_exceptions, :boolean
    add_column :sites, :require_user_email, :boolean
    add_index  :sites, :name, :unique => true
  end

  def self.down
    remove_column :sites, :title
    remove_column :sites, :enforce_ssl
    remove_column :sites, :show_exceptions
    remove_column :sites, :require_user_email
    remove_index  :sites, :name
  end
end

