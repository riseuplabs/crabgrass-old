class RemoveTimesFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :ends_at
    remove_column :pages, :starts_at
  end

  def self.down
    add_column :pages, :starts_at, :datetime
    add_column :pages, :ends_at, :datetime
  end
end
