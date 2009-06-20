class AddAdminGroupAndLoginRedirectToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :council_id, :integer 
    add_column :sites, :login_redirect_url, :string
  end

  def self.down
    remove_column :sites, :council_id
    remove_column :sites, :login_redirect_url
  end
end
