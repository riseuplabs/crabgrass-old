class AddNeedsEmailVerificationToSitesAndUnverifiedToUsers < ActiveRecord::Migration
  def self.up
    # setup the data for email verifications for registration
    add_column :sites, :needs_email_verification, :boolean, :default => false
    add_column :users, :unverified, :boolean, :default => false
  end

  def self.down
    remove_column :sites, :needs_email_verification
    remove_column :users, :unverified
  end
end
