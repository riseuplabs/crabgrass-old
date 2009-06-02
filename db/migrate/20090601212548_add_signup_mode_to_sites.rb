class AddSignupModeToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :signup_mode, :integer, :limit => 1
    add_column :sites, :email_sender_name, :string, :limit => 40
  end

  def self.down
    remove_column :sites, :signup_mode
    remove_column :sites, :email_sender_name
  end
end
