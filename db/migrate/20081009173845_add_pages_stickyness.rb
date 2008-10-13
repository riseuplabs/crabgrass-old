class AddPagesStickyness < ActiveRecord::Migration
  def self.up
    add_column :pages, :static, :boolean
    add_column :pages, :static_expires, :datetime
    add_column :pages, :static_expired, :boolean
  end

  def self.down
    remove_column :pages, :static
    remove_column :pages, :static_expires
    remove_column :pages, :static_expired
  end
end
