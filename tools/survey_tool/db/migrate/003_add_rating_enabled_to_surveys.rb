class AddRatingEnabledToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :rating_enabled, :boolean, :default => false
  end
  
  def self.down
    remove_column :surveys, :rating_enabled
  end
end
