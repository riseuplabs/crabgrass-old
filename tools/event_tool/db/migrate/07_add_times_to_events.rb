class AddTimesToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :starts_at, :datetime
    add_column :events, :ends_at, :datetime
  end

  def self.down
    remove_column :events, :ends_at
    remove_column :events, :starts_at
  end
end
