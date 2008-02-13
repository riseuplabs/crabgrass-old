class AddCreatedAndUpdatedAtToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :created_at,    :datetime
    add_column :tasks, :updated_at,    :datetime
  end

  def self.down
    remove_column :tasks, :created_at
    remove_column :tasks, :updated_at
  end
end
