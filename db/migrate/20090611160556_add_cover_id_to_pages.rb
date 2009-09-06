class AddCoverIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :cover_id, :integer
  end

  def self.down
    remove_column :pages, :cover_id
  end
end
