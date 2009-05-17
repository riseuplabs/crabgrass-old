class AddChatToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :chat, :boolean
  end

  def self.down
    remove_column :sites, :chat
  end
end
