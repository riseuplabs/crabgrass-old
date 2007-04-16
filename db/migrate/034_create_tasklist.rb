class CreateTasklist < ActiveRecord::Migration
  def self.up
    create_table :task_lists do |t|
    end
    create_table :tasks do |t|
      t.column :task_list_id, :integer
      t.column :name, :string, :limit => 50
      t.column :description, :string
      t.column :completed, :boolean, :default => false
      t.column :position, :integer
    end
    create_table :tasks_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :task_id, :integer
    end
  end 

  def self.down
    drop_table :task_lists
    drop_table :tasks
    drop_table :tasks_users
  end
end
