class AddNameToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :name, :string
    add_index :pages, :name
  end

  def self.down
    remove_column :pages, :name
  end
end
