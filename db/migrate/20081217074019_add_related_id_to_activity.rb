class AddRelatedIdToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :related_id, :integer
  end

  def self.down
    remove_column :activities, :related_id
  end
end
