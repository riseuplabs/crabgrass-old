class RemoveNeedsEmailVerificationFromSites < ActiveRecord::Migration
  def self.up
    remove_column :sites, :needs_email_verification
  end

  def self.down
    add_column :sites, :needs_email_verification, :boolean, :default => false
  end
end
