class AddSignupRedirectUrlToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :signup_redirect_url, :string
  end

  def self.down
    remove_column :sites, :signup_redirect_url
  end
end
