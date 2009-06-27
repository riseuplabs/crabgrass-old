class AddActionFieldsToTrackings < ActiveRecord::Migration
  # This is highly MYSQL specific. I use the fact that rails
  # will generate TINYINT(1) columns for :boolean
  def self.up
    add_column :trackings, :views, :boolean
    add_column :trackings, :edits, :boolean
    add_column :trackings, :stars, :boolean
    remove_column :trackings, :action_id
  end

  def self.down
    add_column :trackings, :action_id, :integer
    remove_column :trackings, :views
    remove_column :trackings, :edits
    remove_column :trackings, :stars
  end
end
