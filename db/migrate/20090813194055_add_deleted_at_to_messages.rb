class AddDeletedAtToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :deleted_at, :datetime
  end

  def self.down
    remove_column :messages, :deleted_at
  end
end
